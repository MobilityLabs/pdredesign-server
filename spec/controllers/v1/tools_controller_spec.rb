require 'spec_helper'

describe V1::ToolsController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  before { sign_in Application::create_sample_user }

  describe '#create' do
    it 'can create a tool' do
      phase    = ToolPhase.create(title: 'test', description: 'description') 
      category = ToolCategory.create(title: 'category', tool_phase: phase)
      subcategory = ToolSubcategory.create(title: 'category', tool_category: category)

      post :create, title: 'expected title',
        description: 'some description',
        url: 'http://www.google.com',
        tool_subcategory_id: subcategory.id

      tool = Tool.find_by(title: 'expected title')

      expect(tool).not_to be_nil
      expect(tool[:description]).to eq('some description')
      expect(tool[:url]).to eq('http://www.google.com')
      expect(tool[:tool_subcategory_id]).to eq(subcategory.id)
    end

    it 'returns errors when tool cant be saved' do
      post :create
      expect(json["errors"]).not_to be_empty
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
      expect(json.first["categories"].count).to eq(5)
    end

    it 'returns all subcategories' do
      phase    = ToolPhase.create(title: 'test', description: 'description') 
      category = ToolCategory.create(title: "category", tool_phase: phase)
      5.times do |i|
        ToolSubcategory.create(title: 'Expected Title',
                    tool_category: category)
      end


      get :index
      expect(json.first["categories"].first["subcategories"].count).to eq(5)

    end

    it 'returns all tools' do
      phase       = ToolPhase.create(title: 'test', description: 'description') 
      category    = ToolCategory.create(title: "category 1", tool_phase: phase)
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

      tools = json.first["categories"].first["subcategories"].first["tools"]
      expect(tools.count).to eq(5)

      tools.each { |t| expect(t["url"]).to eq('expected') }
    end

    context 'with data' do
      def create_data
        phase       = ToolPhase.create(title: 'test', description: 'description') 
        category    = ToolCategory.create(title: "category 1", tool_phase: phase)
        subcategory = ToolSubcategory.create(title: 'Expected Title',
                                             tool_category: category)

        district  = District.create!
        
        @creating_user = Application::create_sample_user
        @login_user    = Application::create_sample_user
        @other_user    = Application::create_sample_user

        @creating_user.update(district_ids: [district.id])
        @login_user.update(district_ids: [district.id])

        Tool.create(title: 't',
                    description: 'd',
                    user: @creating_user,
                    tool_subcategory: subcategory)

      end

      it 'returns user created tools' do
        create_data
        sign_in @login_user
        get :index
        tools = json.first["categories"].first["subcategories"].first["tools"]
        expect(tools.count).to eq(1)
      end

      it 'returns user created tools for current district' do
        create_data
        sign_in @other_user

        get :index
        tools = json.first["categories"].first["subcategories"].first["tools"]
        expect(tools.count).to eq(0)
      end
    end
  end

end
