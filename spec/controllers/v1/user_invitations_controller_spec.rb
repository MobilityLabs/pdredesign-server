require 'spec_helper'

describe V1::UserInvitationsController do
  before { create_magic_assessments }
  let(:assessment) { @assessment_with_participants }
  let(:subject) { V1::UserInvitationsController }
  render_views

  before do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe '#create' do
    it 'requires logged in user' do
      sign_out :user
      post :create, assessment_id: assessment.id

      assert_response 401
    end

    it 'requires a facilitator to create a invite' do
      sign_in @user
      post :create, assessment_id: assessment.id

      assert_response :forbidden
    end

    context 'with facilitator' do
      before { sign_in @facilitator2 }
      def valid_post
        post :create,
          assessment_id: assessment.id,
          first_name:    "john",
          last_name:     "doe",
          email:         "john_doe@gmail.com"
      end

      it 'can create an invitation' do
        valid_post

        assert_response :success
        expect(UserInvitation.find_by_email('john_doe@gmail.com')).not_to be_nil
      end

      it 'sets the team_role when is a new participant' do
        params = { first_name: "john", last_name: "doe", email: "johndoe+newuser@mobility-labs.com", team_role: "Finance", assessment_id: assessment.id }
        post :create, params

        assert_response :success
        expect(UserInvitation.find_by(email: 'johndoe+newuser@mobility-labs.com').team_role).not_to be_nil
      end

      it 'returns errors gracefully with errors' do
        post :create,
          assessment_id: assessment.id,
          first_name:    "john",
          last_name:     "doe"

        assert_response 422
        expect(json["errors"]).not_to be_empty
      end

      it 'doesnt allow an already invited user to get invited to the same assessment' do
        UserInvitation.create!(last_name: 'doe',
          first_name: 'john',
          email: 'john_doe@gmail.com',
          assessment_id: assessment.id)
        
        valid_post

        assert_response 422
        expect(json["errors"]["email"]).to include("User has already been invited")
      end

      it 'allows a user to be invited to two assessments' do
        UserInvitation.create!(last_name: 'doe',
          first_name: 'john',
          email: 'john_doe@gmail.com',
          assessment_id: 1)
        
        valid_post

        assert_response :success
      end

    end

    context 'worker' do
      before { sign_in @facilitator2 }

      it 'sends an invite when :send_invite is present' do
        post :create,
          send_invite: true,
          assessment_id: assessment.id,
          first_name:    "john",
          last_name:     "doe",
          email:         "john_doe@gmail.com"

        expect(UserInvitationNotificationWorker.jobs.count).to eq(1)

      end

      it 'does not send an invite' do
        post :create,
          assessment_id: assessment.id,
          first_name:    "john",
          last_name:     "doe",
          email:         "john_doe@gmail.com"

        expect(UserInvitationNotificationWorker.jobs.count).to eq(0)
      end
    end 

  end 
end
