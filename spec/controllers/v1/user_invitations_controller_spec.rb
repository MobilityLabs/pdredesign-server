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

      it 'can create an invitation' do
        post :create,
          assessment_id: assessment.id,
          first_name:    "john",
          last_name:     "doe",
          email:         "john_doe@gmail.com"

        assert_response :success
        expect(UserInvitation.find_by_email('john_doe@gmail.com')).not_to be_nil
      end

      it 'returns errors gracefully with errors' do
        post :create,
          assessment_id: assessment.id,
          first_name:    "john",
          last_name:     "doe"

        assert_response 422
        expect(json["errors"]).not_to be_empty
      end
    end

  end 
end
