require  'spec_helper'

describe V1::AccessRequestController do
  render_views

  before { create_magic_assessments }
  before { sign_in @facilitator2 }
  let(:assessment) { @assessment_with_participants }

  describe '#create' do
    it 'creates a AccessRequest record' do
      post :create,
        assessment_id: assessment.id,
        roles: [:facilitator, :participant], format: :json

      access_request = AccessRequest.find(json["id"])
      expect(access_request.user_id).to eq(@facilitator2.id)
      expect(access_request.roles).to eq(['facilitator', 'participant'])
      expect(access_request.assessment_id).to eq(assessment.id)
      expect(access_request.hash).not_to be_nil
      expect(response).to have_http_status(:success)
    end

    it 'returns errors if not successful' do
      post :create,
        assessment_id: assessment.id, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["errors"]).not_to be_empty
    end

    it 'queues a notification worker' do
      expect(AccessRequestNotificationWorker).to receive(:perform_async)

      post :create,
        assessment_id: assessment.id,
        roles: [:facilitator, :participant], format: :json

      expect(response).to have_http_status(:success)
    end
  end
end
