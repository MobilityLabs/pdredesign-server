require 'spec_helper'

describe V1::ScoresController do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  render_views

  before do 
    create_magic_assessments
    create_struct
    Score.all.destroy_all
  end

  before { sign_in @user }
  let(:assessment) { @assessment_with_participants }

  context '#create' do
    it 'can create a score, and flush cached assessment version' do 
      question = Question.first

      expect_flush_cached_assessment

      post :create, assessment_id: assessment.id, 
                    response_id: 99,
                    question_id: question.id,
                    value: 1,
                    evidence: 'new score' 

      score = Score.find_by(response_id: 99, question_id: question.id) 
      expect(score.evidence).to eq('new score')
    end

    it 'renders errors' do
      question = Question.first

      double = double("Score").as_null_object
      allow(double).to receive(:save).and_return(false)
      allow(double).to receive(:errors).and_return([{'value' => 'is bad'}])
      allow(controller).to receive(:find_or_initialize).and_return(double)

      post :create, assessment_id: assessment.id, 
                    response_id: 99,
                    question_id: question.id,
                    value: 1,
                    evidence: 'new score' 


      expect(response.status).to eq(422)
      expect(json["errors"]).not_to be_empty
    end

    it 'does not allow a non-owner to create a score' do
      sign_in @user2
      question = Question.first
      post :create, assessment_id: assessment.id, 
                    response_id: 99,
                    question_id: question.id,
                    value: 1,
                    evidence: 'new score' 

      assert_response :forbidden
    end

    it 'allows for a skipped answer' do
      question = Question.first
      post :create, assessment_id: assessment.id, 
        response_id: 99,
        question_id: question.id,
        value: nil,
        evidence: 'new score' 

      assert_response :success
    end

    it 'updates an existing score' do
      question = Question.first
      score = Score.create(response_id: 99, 
                   question_id: question.id, 
                   value: 2, 
                   evidence: 'test')

      post :create, assessment_id: assessment.id, 
                    response_id: 99,
                    question_id: question.id,
                    value: 1,
                    evidence: 'new score' 
      score = Score.find(score.id)

      expect(score.value).to eq(1)
      expect(score.evidence).to eq('new score')
    end

    it 'allows a facilitator access to make changes to a consensus' do
      assessment.facilitators << @facilitator
      sign_in @facilitator

      Response.find(99).update(responder: assessment,
                               responder_type: 'Assessment')

      question = Question.first
      post :create, assessment_id: assessment.id,
                    response_id: 99,
                    question_id: question.id,
                    value: 1,
                    evidence: 'new score'

      assert_response :success
    end
  end

  context '#index' do
    it 'gives a list of scores for each question' do
      get :index, assessment_id: assessment.id,
                  response_id: 99

      expect(json.count).to eq(9)
    end

    it 'gives a score for each question' do
      question = Question.first
      score = Score.create(response_id: 99,
        question_id: question.id,
        value: 2,
        evidence: 'test')

      get :index, assessment_id: assessment.id,
                  response_id: 99
      first = json.detect { |q| q["id"] == question.id }
      expect(first["score"]["id"]).to eq(score.id)
    end
  end
end
