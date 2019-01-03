require 'spec_helper'

describe V1::ResponsesController do
  render_views

  before(:each) do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe 'POST #create' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when the user is not a participant of the assessment' do
      let(:user) {
        assessment.facilitators.sample
      }

      before(:each) do
        sign_in user
        post :create, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when the user is a participant of the assessment' do
      context 'when no response prior exists' do
        let(:user) {
          participant.user
        }

        let(:participant) {
          assessment.participants.sample
        }

        before(:each) do
          sign_in user
          post :create, params: { assessment_id: assessment.id }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(Response.where(responder_id: participant.id).count).to eq 1
        }
      end

      context 'when a response exists' do
        let(:user) {
          participant.user
        }

        let(:participant) {
          assessment.participants.sample
        }

        let!(:preexisting_response) {
          create(:response, :as_participant_responder, responder: participant)
        }

        before(:each) do
          sign_in user
          post :create, params: { assessment_id: assessment.id }
        end

        it {
          expect(json['id']).to eq preexisting_response.id
        }
      end
    end
  end

  describe 'GET #show' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when the user is a facilitator' do
      let(:participant) {
        assessment.participants.sample
      }

      let(:participant_response) {
        create(:response, :as_participant_responder, responder: participant)
      }

      let(:user) {
        assessment.facilitators.sample
      }

      before(:each) do
        sign_in user
        get :show, params: {
          assessment_id: assessment.id,
          id: participant_response.id
        }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when a valid response is passed' do
      let(:participant) {
        assessment.participants.sample
      }

      let(:user) {
        participant.user
      }

      let(:participant_response) {
        create(:response, :as_participant_responder, responder: participant)
      }

      before(:each) do
        sign_in user
        get :show, params: {
          assessment_id: assessment.id,
          id: participant_response.id
        }
      end

      it {
        expect(assigns(:rubric)[:id]).to eq assessment.rubric.id
      }

      it {
        expect(json["id"]).to eq participant_response.id
      }
    end
  end

  describe 'GET #show_slimmed' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when the user is a facilitator' do
      let(:participant) {
        assessment.participants.sample
      }

      let(:participant_response) {
        create(:response, :as_participant_responder, responder: participant)
      }

      let(:user) {
        assessment.facilitators.sample
      }

      before(:each) do
        sign_in user
        get :show_slimmed, params: {
          assessment_id: assessment.id,
          response_id: participant_response.id
        }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when a valid response is passed' do
      let(:participant) {
        assessment.participants.sample
      }

      let(:user) {
        participant.user
      }

      let(:participant_response) {
        create(:response, :as_participant_responder, responder: participant)
      }

      before(:each) do
        sign_in user
        get :show_slimmed, params: {
          assessment_id: assessment.id,
          response_id: participant_response.id
        }
      end

      it {
        expect(assigns(:rubric)[:id]).to eq assessment.rubric.id
      }

      it {
        expect(json["id"]).to eq participant_response.id
      }
    end
  end

  describe 'PUT #update' do

    let(:preexisting_response) {
      create(:response, :as_participant_responder, responder: participant)
    }

    let(:participant) {
      assessment.participants.sample
    }

    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when the user is not the owner of the response' do
      let(:user) {
        assessment.user
      }

      before(:each) do
        sign_in user
        put :update, params: {
          assessment_id: assessment.id,
          id: preexisting_response.id,
          submit: true
        }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when the user is the owner of the response' do
      let(:user) {
        participant.user
      }

      before(:each) do
        sign_in user
        put :update, params: {
          assessment_id: assessment.id,
          id: preexisting_response.id,
          submit: true
        }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        preexisting_response.reload
        expect(preexisting_response.submitted_at).to_not be_nil
      }

      it {
        expect(ResponseCompletedNotificationWorker.jobs.size).to eq 1
      }
    end
  end
end
