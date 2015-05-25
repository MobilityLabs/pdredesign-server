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

  context '#create' do
    it 'sends an invite when :send_invite is present' do
      sign_in @facilitator

      double = double("AssessmentMailer")

      expect(double).to receive(:deliver_now)
      expect(AssessmentsMailer).to receive(:assigned).and_return(double)

      other = Assessment.find_by_name("Assessment 1")
      post :create, assessment_id: other.id, user_id: @user.id, send_invite: true
      assert_response :success
    end

    it 'can create a participant' do
      sign_in @facilitator

      other = Assessment.find_by_name("Assessment 1")

      expect_flush_cached_assessment

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
    
    it 'deletes any invitations that are pending for the user' do
      user_id = @participant.user.id

      UserInvitation
        .create!(id: 42,
                 first_name: 'some',
                 last_name: 'user',
                 assessment_id: assessment.id,
                 user_id: user_id,
                 email: @participant.user.email) 

      delete :destroy, assessment_id: assessment.id, id: @participant.id 
      expect(UserInvitation.where(user_id: user_id)).to be_empty
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
      Application::create_sample_user(
        districts: [@district2],
        role: :district_member)

      get :all, assessment_id: assessment.id  

      assert_response :success
      participants = assigns(:users)

      expect(participants.count).to eq(2)
    end

    it 'does not return participants already in assessment' do
      get :all, assessment_id: assessment.id  

      participants = assigns(:users)
      expect(participants.count).to eq(1)
    end

    it 'does not return network partners' do

      Application::create_sample_user(
        districts: [@district2],
        role: :network_partner)

      Application::create_sample_user(
        districts: [@district2],
        role: nil)

      get :all, assessment_id: assessment.id  

      participants = assigns(:users)
      expect(participants.count).to eq(2)
    end


    it 'forbids non-facilitators users' do
      sign_in @user
      get :all, assessment_id: assessment.id  
      assert_response :forbidden
    end
  end

  describe '#mail' do
    it 'does not allow a non-facilitator user' do
      sign_in @user
      get :mail, assessment_id: assessment.id, participant_id: @participant.id
      assert_response :forbidden
    end

    it 'allows facilitators' do
      sign_in @facilitator2
      get :mail, assessment_id: assessment.id, participant_id: @participant.id
      assert_response :success
    end

    context 'with facilitator' do
      before { sign_in @facilitator2 }

      it 'returns a 404 when the participant is not found' do
        get :mail, assessment_id: assessment.id, participant_id: 0
        assert_response :missing
      end

      it 'returns the invitation email body of assigned email' do
        double = double('AssessmentMailer', text_part: OpenStruct.new(body: 'expected'))
        allow(AssessmentsMailer).to receive(:assigned).and_return(double)

        get :mail, assessment_id: assessment.id, participant_id: @participant.id
        expect(response.body).to eq('expected')
      end

      it 'returns the invitation email body of the user invitation email' do
        double = double('AssessmentMailer', text_part: OpenStruct.new(body: 'expected'))
        allow(NotificationsMailer).to receive(:invite).and_return(double)

        UserInvitation.create!(user_id: @participant.user.id,
                               assessment_id: assessment.id,
                               email: 'example_user@gmail.com')
        get :mail, assessment_id: assessment.id, participant_id: @participant.id
        expect(response.body).to eq('expected')

      end
    end
  end

end
