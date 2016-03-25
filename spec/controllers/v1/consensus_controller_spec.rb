require 'spec_helper'

describe V1::ConsensusController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  before { create_magic_assessments }
  before { sign_in @user }
  let(:assessment) { @assessment_with_participants }

  context 'fake non-consensus' do
    before do
      Response.create(responder_id:   @participant.id,
                      responder_type: 'Participant',
                      id: 42)
      create_struct
    end

    it 'requires a login to show' do
      sign_out :user

      get :show, assessment_id: 1, id: 1
      assert_response 401
    end

    it 'only returns consensus response' do
      sign_in @user3
      get :show, assessment_id: assessment.id, id: 42
      assert_response :not_found
    end
  end

  context 'with valid consensus' do
    before do
      Response.create(responder_id:   @assessment_with_participants.id,
                      responder_type: 'Assessment',
                      id: 42)
      create_struct
    end

    it 'can get a consensus' do
      get :show, assessment_id: assessment.id, id: 42
      assert_response :success
    end

    it 'renders the consensus partial' do
      get :show, assessment_id: assessment.id, id: 42
      assert_template partial: 'v1/consensus/_consensus'
    end

    describe '#show' do
      it 'returns scores for provided team_role' do
        get :show, assessment_id: assessment.id, id: 42, team_role: :stuff
        expect(assigns(:team_role)).to eq("stuff")
      end

      it 'assigns :team_roles' do
        get :show, assessment_id: assessment.id, id: 42
        expect(assigns(:team_roles)).not_to be_nil
      end
    end

    describe '#update' do
      it 'doesnt allow user to update' do
        sign_in @user
        put :update, assessment_id: assessment.id, id: 42, submit: true
        assert_response :forbidden
      end

      it 'submits consensus with the right owner' do
        sign_in @facilitator2

        put :update, assessment_id: assessment.id, id: 42, submit: true
        response = Response.find(42)

        assert_response :success
        expect(response.submitted_at).not_to be_nil
      end

      it "submits consensus and the assessment chached version should be flushed" do
        sign_in @facilitator2
        expect_flush_cached_assessment

        put :update, assessment_id: assessment.id, id: assessment.consensus.id, submit: true; assessment.reload
      end
    end
  end

  describe '#create' do
    it 'requires a participant to create and owner' do
      sign_out :user

      post :create, assessment_id: assessment.id
      assert_response 401
    end

    it 'only owner can create consensus' do
      sign_in @user

      post :create, assessment_id: assessment.id
      assert_response :forbidden
    end


    it 'can create a new consensus' do
      sign_in @facilitator2

      expect_flush_cached_assessment

      post :create, assessment_id: assessment.id
      assert_response :success

      consensus = Response.find_by(responder_type: 'Assessment',
                       responder_id: assessment.id)

      expect(consensus).not_to be_nil
      expect(consensus.rubric).not_to be_nil
      expect(assessment.has_response?).to eq(true)
    end

    it 'does not error when a consensus already exists' do
      consensus = Response.create!(
                    rubric: assessment.rubric,
                    responder_type: 'Assessment',
                    responder_id: assessment.id)

      sign_in @facilitator2

      post :create, assessment_id: assessment.id
      assert_response :success

    end
  end

  describe 'GET #evidence' do
    before(:each) do
      sign_out @user
    end

    context 'when unauthenticated' do
      before(:each) do
        get :evidence, assessment_id: 1, question_id: 1
      end

      it 'requires authentication' do
        expect(response.status).to eq 401
      end
    end

    context 'when there is no evidence' do

      let(:user) {
        FactoryGirl.create(:user)
      }

      let(:assessment) {
        FactoryGirl.create(:assessment, :with_response, user: user)
      }

      before(:each) do
        sign_in user
        get :evidence, assessment_id: assessment.id, question_id: 1
      end

      it 'returns an empty JSON array' do
        expect(json.size).to eq 0
      end
    end

    context 'when there is evidence' do

      let(:user) {
        FactoryGirl.create(:user)
      }

      let!(:participants) {
        FactoryGirl.create_list(:participant, 1, assessment: assessment)
      }

      let(:assessment) {
        FactoryGirl.create(:assessment, :with_response, user: user)
      }

      let!(:preexisting_response) {
        FactoryGirl.create(:response, responder_type: 'Participant', responder: participants.first)
      }

      let(:score) {
        FactoryGirl.create(:score, response: preexisting_response)
      }

      before(:each) do
        sign_in user
        get :evidence, assessment_id: assessment.id, question_id: score.question_id
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

