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
        get :show, assessment_id: assessment.id, consensus_id: 42, team_role: :stuff
        expect(assigns(:team_role)).to eq("stuff")
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

      post :create, assessment_id: assessment.id
      assert_response :success

      consensus = Response.find_by(responder_type: 'Assessment',
                       responder_id: assessment.id)

      expect(consensus).not_to be_nil
      expect(consensus.rubric).not_to be_nil
      expect(assessment.has_response?).to eq(true)
    end

  end
end

