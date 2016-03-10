require 'spec_helper'

describe V1::SharedAssessmentsController do
  render_views

  describe '#show' do
    let(:facilitator) { FactoryGirl.create :user, :with_facilitator_role }
    let(:rubric) { FactoryGirl.create :rubric }
    let(:district) { FactoryGirl.create :district }
    let(:assessment) { FactoryGirl.create :assessment, rubric: rubric, district: district, user: facilitator }

    context 'with valid token' do
      let(:token) { assessment.share_token }

      before(:each) do
        get :show, token: token, format: :json
      end

      it do
        expect(response).to have_http_status(:success)
      end

      it do
        expect(assigns(:assessment).id).to eq(assessment.id)
      end
    end

    context 'with invalid token' do
      let(:token) { 'foo-bar-invalid-token' }

      it do
        get :show, token: token, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
