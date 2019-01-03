require 'spec_helper'

describe V1::RemindersController do
  render_views

  before(:each) do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe 'POST #create' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when the user is a participant' do
      let(:user) {
        assessment.participants.sample.user
      }

      before(:each) do
        sign_in user
        post :create, params: { assessment_id: assessment.id, message: 'Some reminder' }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when the user is a facilitator' do
      let(:user) {
        assessment.facilitators.sample
      }

      before(:each) do
        sign_in user
        post :create, params: { assessment_id: assessment.id, message: 'Reminder' }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(ReminderNotificationWorker.jobs.size).to eq 1
      }
    end
  end
end
