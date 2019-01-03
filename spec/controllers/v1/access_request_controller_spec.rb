require  'spec_helper'

describe V1::AccessRequestController do
  render_views

  let(:assessment) {
    create(:assessment, :with_participants)
  }

  let(:facilitator) {
    assessment.facilitators.sample
  }

  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  describe '#create' do
    context 'when not authenticated' do
      before(:each) do
        sign_out :user
        post :create, params: { assessment_id: assessment.id, roles: %i|0 1| }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when authenticated' do
      context 'when successful' do
        before(:each) do
          sign_in facilitator
          post :create, params: { assessment_id: assessment.id, roles: %i|0 1| }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          access_request = AccessRequest.find(json["id"])
          expect(access_request.user_id).to eq(facilitator.id)
        }

        it {
          access_request = AccessRequest.find(json["id"])
          expect(access_request.roles).to eq(%w(facilitator participant))
        }

        it {
          access_request = AccessRequest.find(json["id"])
          expect(access_request.tool_id).to eq(assessment.id)
        }

        it {
          access_request = AccessRequest.find(json["id"])
          expect(access_request.hash).not_to be_nil
        }
      end

      context 'when unsuccessful' do
        before(:each) do
          sign_in facilitator
          post :create, params: { assessment_id: assessment.id }
        end

        it {
          is_expected.to respond_with :unprocessable_entity
        }

        it {
          expect(json['errors']).not_to be_empty
        }
      end

      context 'when successful and queuing a notification worker' do
        before(:each) do
          sign_in facilitator
          expect(AccessRequestNotificationWorker).to receive(:perform_async)
          post :create, params: { assessment_id: assessment.id, roles: %i|0 1| }
        end

        it {
          is_expected.to respond_with :success
        }
      end
    end
  end
end
