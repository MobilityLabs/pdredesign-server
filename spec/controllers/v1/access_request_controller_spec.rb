require  'spec_helper'

describe V1::AccessRequestController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  before { create_magic_assessments }
  before { sign_in @facilitator2 }
  let(:assessment) { @assessment_with_participants }

  describe '#create' do
    it 'creates a AccessRequest record' do
      post :create,
        assessment_id: assessment.id,
        roles: [:facilitator, :participant]

      access_request = AccessRequest.find(json["id"])
      expect(access_request.user_id).to eq(@facilitator2.id)
      expect(access_request.roles).to eq(['facilitator', 'participant'])
      expect(access_request.assessment_id).to eq(assessment.id)
      expect(access_request.hash).not_to be_nil
      assert_response :success
    end

    it 'returns errors if not successful' do
      post :create,
        assessment_id: assessment.id

      assert_response 422
      expect(json["errors"]).not_to be_empty
    end

    it 'queues a notification worker' do
      expect(AccessRequestNotificationWorker).to receive(:perform_async)

      post :create,
        assessment_id: assessment.id,
        roles: [:facilitator, :participant]

      assert_response :success
    end

  end
end
