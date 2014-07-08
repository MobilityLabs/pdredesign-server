require 'spec_helper'

describe V1::ParticipantsController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  before { create_magic_assessments }
  before { sign_in @facilitator2 }
  let(:assessment) { @assessment_with_participants }

  context '#index' do
    it 'can get participants' do
      get :index, assessment_id: assessment.id
      assert_response :success 
    end
    
    it 'requires a user' do
      sign_out :user
      get :index, assessment_id: assessment.id
      assert_response 401
    end

    it 'gets a list of participants' do
      get :index, assessment_id: assessment.id
      participants = assigns(:participants)
      expect(participants.count).to eq(2) 
    end

    it 'gets a list of participants' do
      get :index, assessment_id: assessment.id

      participants = assigns(:participants)
      expect(participants.count).to eq(2) 
    end

  end

  context '#new' do
    it 'can create a participant' do
      sign_in @facilitator

      other = Assessment.find_by_name("Assessment 1")
      post :create, assessment_id: other.id, user_id: @user.id 

      assert_response :success
      participants = Participant
        .where(assessment_id: other.id, user_id: @user.id)

      expect(participants.count).to eq(1)
    end

    it 'forbids non-owner to create' do
      sign_in @user

      other = Assessment.find_by_name("Assessment 1")
      post :create, assessment_id: other.id, user_id: @user.id 
      assert_response :forbidden
    end
  end

  context '#destroy' do
    it 'can delete a participant' do
      expect(Participant.where(id: @participant.id).count).to eq(1)

      delete :destroy, assessment_id: assessment.id, id: @participant.id 
      assert_response :success

      expect(Participant.where(id: @participant.id).count).to eq(0)
    end
    
    it 'returns 404 when missing participant' do
      delete :destroy, assessment_id: assessment.id, id: 000000
      assert_response :missing
    end

    it 'forbids non-owner to delete' do
      sign_in @user
      delete :destroy, assessment_id: assessment.id, id: @participant.id
      assert_response :forbidden
    end
  end

  context '#all' do
    it 'gives a list of all participants in assessment district' do
      get :all, assessment_id: assessment.id  

      Application::create_sample_user(
        districts: [@district2],
        role: :member)

      assert_response :success
      participants = assigns(:users)

      expect(participants.count).to eq(2)
    end

    it 'does not return participants already in assessment' do
      get :all, assessment_id: assessment.id  

      participants = assigns(:users)
      expect(participants.count).to eq(1)
    end

    it 'forbids non-facilitators users' do
      sign_in @user
      get :all, assessment_id: assessment.id  
      assert_response :forbidden
    end
  end

end
