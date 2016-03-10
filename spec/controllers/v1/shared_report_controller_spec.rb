require  'spec_helper'

describe V1::SharedReportController do
  render_views

  before { create_magic_assessments }
  before { create_struct }
  let(:assessment) { @assessment_with_participants }
  let(:consensu){ assessment.response.nil? ? Response.create(responder_id:   assessment.id, responder_type: 'Assessment') : assessment.response }

  describe '#show' do
    it 'gets a report' do
      get :show, shared_token: assessment.share_token, format: :json
      expect(response).to have_http_status(:success)
    end

    it 'assigns the assessment' do
      get :show, shared_token: assessment.share_token, format: :json
      expect(assigns(:assessment).id).to eq(assessment.id)
    end

    it 'assigns the axes' do
      get :show, shared_token: assessment.share_token, format: :json
      expect(assigns(:axes)).not_to be_nil
    end 
  end
end
