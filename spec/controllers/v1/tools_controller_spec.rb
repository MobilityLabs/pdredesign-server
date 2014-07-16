require 'spec_helper'

describe V1::ToolsController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe '#create' do
    it 'can create a tool' do
      phase    = ToolPhase.create(title: 'test', description: 'description') 
      category = ToolCategory.create(title: 'category', tool_phase: phase)

      post :create, title: 'expected title',
        description: 'some description',
        url: 'http://www.google.com',
        district_id: 1,
        tool_category_id: category.id

      tool = Tool.find_by(title: 'expected title')
      expect(tool).not_to be_nil
      expect(tool[:description]).to eq('some description')
      expect(tool[:url]).to eq('http://www.google.com')
      expect(tool[:tool_category_id]).to eq(category.id)
    end

    it 'returns errors when tool cant be saved' do
      post :create
      expect(json["errors"]).not_to be_empty
    end

    it 'requires a district_id' do
      post :create
      expect(json["errors"]["district_id"]).not_to be_nil
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
                    district_id: 1,
                    tool_category: category,
                    tool_subcategory: subcategory,
                    url: 'expected')
      end

      get :index

      tools = json.first["categories"].first["subcategories"].first["tools"]
      expect(tools.count).to eq(5)

      tools.each { |t| expect(t["url"]).to eq('expected') }
    end

  end

end
