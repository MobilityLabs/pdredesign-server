require  'spec_helper'

describe V1::ReportController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  before { create_magic_assessments }
  before { create_struct }
  before { sign_in @user2 }
  let(:assessment) { @assessment_with_participants }
  let(:consensu){ Response.create(responder_id:   assessment.id, responder_type: 'Assessment') }

  context '#show' do

    it 'requires a user login' do
      sign_out :user
      get :show, assessment_id: 1
      assert_response 401
    end

    it 'gets a report' do
      get :show, assessment_id: assessment.id
      assert_response :success
    end

    it 'updates the participants viewed report time' do
      get :show, assessment_id: assessment.id

      participant = Participant
        .find_by(assessment: assessment, user: @user2)

      expect(participant[:report_viewed_at]).not_to be_nil
    end

    it 'assigns the assessment' do
      get :show, assessment_id: assessment.id
      expect(assigns(:assessment).id).to eq(assessment.id)
    end

    it 'assigns the axes' do
      get :show, assessment_id: assessment.id
      expect(assigns(:axes)).not_to be_nil
    end 

    it 'assigns response' do
      assessment.update(response: Response.find(99))
      get :show, assessment_id: assessment.id
      expect(assigns(:response)).not_to be_nil
    end

    it 'does not allow non-participants' do
      sign_in @user3
      get :show, assessment_id: assessment.id
      assert_response :forbidden
    end

  end

  context "#consensus_report" do

    it 'get the consensus report response' do
      get :consensus_report, assessment_id: assessment.id, consensu_id: consensu.id

      expect(json["participants"].count).to eq(assessment.participants.count)
      expect(json["participant_count"]).not_to be_nil
      expect(json["questions"]).to be_kind_of(Array)
      expect(json["scores"]).to be_kind_of(Array)
      assert_response 200
    end

    it 'render not found when consensus does not exist' do
      get :consensus_report, assessment_id: assessment.id, consensu_id: 9990
      assert_response 404
    end

    it 'requires a user login' do
      sign_out :user
      get :consensus_report, assessment_id: 1, consensu_id: 1
      assert_response 401
    end
  end

  context "#participant_consensu_report" do
    it 'get the participant consensus report' do
      get :participant_consensu_report, assessment_id: assessment.id, consensu_id: consensu.id, participant_id: @participant.id
      
      expect(json["questions"]).to be_kind_of(Array)
      expect(json["consensu_id"]).not_to be_nil
      expect(json["assessment_id"]).not_to be_nil
      expect(json["participant_id"]).not_to be_nil

      assert_response 200
    end

    it 'render not found when consensus does not exist' do
      get :participant_consensu_report, assessment_id: 900, consensu_id: 900, participant_id: 800
      assert_response 404
    end

    it 'requires a user login' do
      sign_out :user
      get :participant_consensu_report, assessment_id: 1, consensu_id: 1, participant_id: 1
      assert_response 401
    end
  end


end