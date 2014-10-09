require 'spec_helper'

describe V1::FaqsController do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  render_views
  
  before :all do 
    Faq::Question.destroy_all
  end

  describe '#index' do
    def create_questions(count = 3)
      category = Faq::Category.create!(heading: 'example')
      count.times do 
        Faq::Question.create!(
          content: 'test', 
          role: 'facilitator',
          category: category,
          answer: 'test') 
      end
    end

    before do
      create_questions
    end

    it 'returns the list of FAQ Questions' do
      get :index
      expect(json.count).to eq(3)
    end

    it 'returns the correct fields' do
      get :index
      question = json.first
      expect(question["id"]).not_to be_nil
      expect(question["role"]).to eq('facilitator')
      expect(question["content"]).to eq('test')
      expect(question["answer"]).to eq('test')
    end

    it 'returns the category' do
      get :index
      question = json.first
      expect(question["category"]["heading"]).to eq('example')
    end


  end


end
