require 'spec_helper'

describe V1::ToolsController do
  render_views

  let(:partner) {
    FactoryGirl.create(:user, :with_district, :with_network_partner_role)
  }

  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'
    sign_in partner
  end

  describe '#create' do

    it 'requires a user' do
      sign_out :user

      post :create
      assert_response :unauthorized
    end

    it 'can create a tool' do
      phase    = ToolPhase.create(title: 'test', description: 'description') 
      category = ToolCategory.create(title: 'category', tool_phase: phase)
      subcategory = ToolSubcategory.create(title: 'category', tool_category: category)

      post :create, params: {
        title: 'expected title',
        description: 'some description',
        url: 'http://www.google.com',
        tool_subcategory_id: subcategory.id
      }

      tool = Tool.find_by(title: 'expected title')

      expect(tool).not_to be_nil
      expect(tool[:description]).to eq('some description')
      expect(tool[:url]).to eq('http://www.google.com')
      expect(tool[:tool_subcategory_id]).to eq(subcategory.id)
    end

    it 'responds with the tool as json upon creation' do
      phase    = ToolPhase.create(title: 'test', description: 'description') 
      category = ToolCategory.create(title: 'category', tool_phase: phase)
      subcategory = ToolSubcategory.create(title: 'category', tool_category: category)

      post :create, params:{
        title: 'expected title',
        description: 'some description',
        url: 'http://www.google.com',
        tool_subcategory_id: subcategory.id
      }

      tool = Tool.find_by(title: 'expected title')

      expect(json).to eq({
        "id" => tool.id,
        "title" => "expected title",
        "description" => "some description",
        "url" => "http://www.google.com",
        "is_default" => nil,
        "display_order" => nil,
        "tool_subcategory_id" => subcategory.id,
        "user_id" => partner.id,
        "tool_category_id" => nil
      })
    end

    it 'can create a tool with a category id' do
      phase    = ToolPhase.create(title: 'test', description: 'description') 
      category = ToolCategory.create(title: 'category', tool_phase: phase)

      post :create, params: {
        title: 'expected title',
        description: 'some description',
        url: 'http://www.google.com',
        tool_category_id: category.id
      }

      tool = Tool.find_by(title: 'expected title')
      expect(tool).not_to be_nil
      expect(tool[:tool_category_id]).to eq(category.id)
    end

    it 'returns errors when tool cant be saved' do
      post :create
      expect(json['errors']).not_to be_empty
    end

  end

  describe '#index' do
    it 'returns all phases' do
      5.times do |i|
        ToolPhase.create(title: "Phase #{i}", description: "Desc")
      end

      get :index
      expect(json.count).to eq(5)
    end

    it 'returns all categories' do
      phase = ToolPhase.create(title: 'test', description: 'description') 
      5.times do |i|
        ToolCategory.create(title: "category #{i}", tool_phase: phase)
      end

      get :index
      expect(json.first['categories'].count).to eq(5)
    end

    it 'returns all subcategories' do
      phase    = ToolPhase.create(title: 'test', description: 'description') 
      category = ToolCategory.create(title: 'category', tool_phase: phase)
      5.times do |i|
        ToolSubcategory.create(title: 'Expected Title',
                    tool_category: category)
      end


      get :index
      expect(json.first['categories'].first['subcategories'].count).to eq(5)

    end

    it 'returns all tools' do
      phase       = ToolPhase.create(title: 'test', description: 'description') 
      category    = ToolCategory.create(title: 'category 1', tool_phase: phase)
      subcategory = ToolSubcategory.create(title: 'Expected Title',
                      tool_category: category)
      5.times do |i|
        Tool.create(title: 'Expected Title',
                    description: 'desc',
                    is_default: true,
                    tool_subcategory: subcategory,
                    url: 'expected')
      end

      get :index

      tools = json.first['categories'].first['subcategories'].first['tools']
      expect(tools.count).to eq(5)

      tools.each { |t| expect(t['url']).to eq('expected') }
    end

    context 'with data' do
      def create_data
        @phase       = ToolPhase.create(title: 'test', description: 'description') 
        @category    = ToolCategory.create(title: "category 1", tool_phase: @phase)
        @subcategory = ToolSubcategory.create(title: 'Expected Title',
                                             tool_category: @category)

        district  = District.create!
        
        @creating_user = FactoryGirl.create(:user, :with_district)
        @login_user    = FactoryGirl.create(:user, :with_district)
        @other_user    = FactoryGirl.create(:user, :with_district)

        @creating_user.update(district_ids: [district.id])
        @login_user.update(district_ids: [district.id])

        Tool.create(title: 't',
                    description: 'd',
                    user: @creating_user,
                    tool_subcategory: @subcategory)

        
      end

      before { create_data }

      it 'returns user created tools for subcategory' do
        sign_in @login_user
        get :index
        tools = json.first['categories'].first['subcategories'].first['tools']
        expect(tools.count).to eq(1)
      end

      context 'with category level tool' do
        before do 
         Tool.create(title: 'example tool',
            description: 'some desc',
            user: @creating_user,
            tool_category_id: @category.id)
        end

        it 'returns user created tools for categories' do
          sign_in @login_user

          get :index
          tools = json.first['categories'].first['tools']

          expect(tools.count).to eq(1)
          expect(tools.first['title']).to eq('example tool')
        end

        it 'does not return other district users tools' do
           sign_in @other_user

          get :index
          tools = json.first['categories'].first['tools']
          expect(tools.count).to eq(0)
        end
      end

      it 'does not return duplicates if part of multiple districts' do
        district2 = District.create!
        @creating_user.districts << district2
        @login_user.districts << district2

        sign_in @login_user
        get :index
        tools = json.first['categories'].first['subcategories'].first['tools']
        expect(tools.count).to eq(1)

      end

      it 'returns user created tools for current district' do
        sign_in @other_user

        get :index
        tools = json.first['categories'].first['subcategories'].first['tools']
        expect(tools.count).to eq(0)
      end
    end
  end
end
