require 'spec_helper'

describe V1::ConsensusController do
  render_views

  before(:each) do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe 'PUT #update' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    let!(:response) {
      create(
        :response,
        rubric: assessment.rubric,
        responder: assessment,
        submitted_at: nil
      )
    }

    context 'when the user is not a facilitator for the assessment' do
      let(:non_facilitator) {
        create(:user)
      }

      before(:each) do
        sign_in non_facilitator
        put :update, params: { assessment_id: assessment.id, id: response.id, submit: true }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when the user is a facilitator for the assessment' do
      context 'when the submit parameter is false' do
        let(:facilitator) {
          assessment.facilitators.sample
        }

        before(:each) do
          sign_in facilitator
          put :update, params: {
            assessment_id: assessment.id,
            id: response.id,
            submit: false
          }, as: :json
          response.reload
        end

        it {
          expect(response.submitted_at).to be_nil
        }
      end

      context 'when the submit parameter is true' do
        let(:facilitator) {
          assessment.facilitators.sample
        }

        before(:each) do
          sign_in facilitator
          put :update, params: { assessment_id: assessment.id, id: response.id, submit: true }
          response.reload
        end

        it {
          expect(response.submitted_at).not_to be_nil
        }
      end
    end
  end

  describe 'GET #show' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    let(:response) {
      create(:response, responder: assessment)
    }

    context 'when the user is not authenticated' do
      before(:each) do
        sign_out :user
        get :show, params: { assessment_id: assessment.id, id: response.id }
      end

      it {
        is_expected.to respond_with :unauthorized
      }
    end

    context 'when the response does not exist' do
      let(:user) {
        create(:user)
      }

      before(:each) do
        sign_in user
        get :show, params: { assessment_id: assessment.id, id: 0 }
      end

      it {
        is_expected.to respond_with :not_found
      }
    end

    context 'when the response exists' do

      context 'when the team_role param is not passed' do
        let(:user) {
          create(:user)
        }

        before(:each) do
          sign_in user
          get :show, params: { assessment_id: assessment.id, id: response.id }
        end

        it {
          is_expected.to respond_with :success
        }

        it {
          expect(assigns(:team_roles)).to_not be_nil
        }
      end

      context 'when the team_role param is passed' do
        let(:user) {
          create(:user)
        }

        before(:each) do
          sign_in user
          get :show, params: {
            assessment_id: assessment.id,
            id: response.id,
            team_role: 'role'
          }
        end

        it {
          expect(assigns(:team_role)).to eq 'role'
        }
      end
    end
  end

  describe 'POST #create' do
    let(:facilitator) {
      assessment.facilitators.sample
    }

    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when the user is not a facilitator of the assessment' do
      let(:non_facilitator) {
        create(:user)
      }

      let(:assessment) {
        create(:assessment, :with_participants)
      }

      before(:each) do
        sign_in non_facilitator
        post :create, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :forbidden
      }
    end

    context 'when a consensus does not exist for this assessment' do
      before(:each) do
        sign_in facilitator
        post :create, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :success
      }

      it {
        expect(Response.find_by(responder: assessment)).to_not be_nil
      }

      it {
        expect(Response.find_by(responder: assessment).rubric).to_not be_nil
      }

      it {
        assessment.reload
        expect(assessment.has_response?).to be true
      }
    end

    context 'when a consensus already exists for this assessment' do
      let!(:response) {
        create(:response, rubric: assessment.rubric, responder: assessment)
      }

      before(:each) do
        sign_in facilitator
        post :create, params: { assessment_id: assessment.id }
      end

      it {
        is_expected.to respond_with :success
      }
    end
  end

  describe 'GET #evidence' do
    before(:each) do
      sign_out :user
    end

    context 'when unauthenticated' do
      before(:each) do
        get :evidence, params: { assessment_id: 1, question_id: 1 }
      end

      it 'requires authentication' do
        expect(response.status).to eq 401
      end
    end

    context 'when there is no evidence' do

      let(:user) {
        create(:user)
      }

      let(:assessment) {
        create(:assessment, :with_response, :with_participants, user: user)
      }

      before(:each) do
        sign_in user
        get :evidence, params: { assessment_id: assessment.id, question_id: 1 }
      end

      it 'returns an empty JSON array' do
        expect(json.size).to eq 0
      end
    end

    context 'when there is evidence' do

      let(:user) {
        create(:user)
      }

      let!(:participants) {
        create_list(:participant, 1, assessment: assessment)
      }

      let(:assessment) {
        create(:assessment, :with_response, :with_participants, user: user)
      }

      let!(:preexisting_response) {
        create(:response, responder_type: 'Participant', responder: participants.first)
      }

      let(:score) {
        create(:score, response: preexisting_response)
      }

      before(:each) do
        sign_in user
        get :evidence, params: { assessment_id: assessment.id, question_id: score.question_id }
      end

      it 'send back a non-empty JSON array' do
        expect(json.size).not_to eq 0
      end

      it 'sends back the score ID' do
        expect(json[0]['id']).to eq score.id
      end

      it 'sends back the score value' do
        expect(json[0]['value']).to eq score.value
      end

      it 'sends back the score evidence' do
        expect(json[0]['evidence']).to eq score.evidence
      end

      it 'sends back the score response_id' do
        expect(json[0]['response_id']).to eq score.response_id
      end

      it 'sends back the score question_id' do
        expect(json[0]['question_id']).to eq score.question_id
      end

      it 'sends back the score created_at date' do
        expect(json[0]['created_at']).to eq score.created_at.iso8601(3)
      end

      it 'sends back a participant' do
        expect(json[0]['participant']).to_not be_nil
      end
    end
  end
end

