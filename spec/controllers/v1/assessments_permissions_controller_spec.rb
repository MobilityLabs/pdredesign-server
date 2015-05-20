require 'spec_helper'

describe V1::AssessmentsPermissionsController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
    create_magic_assessments
  end

  let(:assessment) { @assessment_with_participants }

  describe '#index' do
    context 'respond to GET#index' do
      before do

        Application.request_access_to_assessment(assessment: assessment, user: Application.create_user, roles: ["facilitator"])
      end

      it 'responds successfully to GET#show' do
        sign_in @facilitator2

        get :index, assessment_id: assessment.id
        assert_response :success 
        expect(response.body).to match(/roles/)
      end

      it 'security: responds with 401 auth error' do
        get :index, assessment_id: assessment.id
        assert_response :unauthorized
      end
    end
  end

  describe '#show' do
    context 'respond to GET#show' do
      it 'responds successfully to GET#show' do
        ar = Application.request_access_to_assessment(assessment: assessment, user: Application.create_user, roles: ["facilitator"])
        sign_in @facilitator2

        get :show, assessment_id: assessment.id, id: ar.id, email: ar.user.email
        assert_response :success
        expect(response.body).to match(/roles/)
      end

      it 'responds 404 to GET#show' do
        sign_in @facilitator2

        get :show, assessment_id: assessment.id, id: 1
        assert_response :missing
      end

      it 'security: responds with 401 auth error' do
        get :show, assessment_id: assessment.id, id: 1
        assert_response :unauthorized
      end

      it 'security: regular user should not be allowed to update the permissions' do
        brand_new_user = Application.create_user
        sign_in brand_new_user

        get :show, assessment_id: assessment.id, id: 1
        assert_response :forbidden
      end
    end
  end

  describe '#update' do
    context 'respond to PUT#update' do
      let(:brand_new_user) { Application.create_user }      

      it 'responds successfully to PUT#update' do
        ra = Application.request_access_to_assessment(assessment: assessment, user: brand_new_user, roles: ["facilitator"])
        sign_in @facilitator2

        put :update, assessment_id: assessment.id, id: ra.id, 
          permissions: [ { level: "facilitator", email: brand_new_user.email }]

        expect(assessment.facilitator?(brand_new_user)).to eq(true)
        assert_response :success
      end

      it 'security: responds with 401 auth error' do
        put :update, assessment_id: assessment.id, id: 1
        assert_response :unauthorized
      end

      it 'security: regular user should not be allowed to update the permissions' do
        sign_in brand_new_user

        put :update, assessment_id: assessment.id, id: 1
        assert_response :forbidden
      end
    end
  end

  describe "GET#current_level - for current_user" do

    it 'returns the current_user permission level' do
      sign_in @facilitator2

      assert_response :success
    end

    it 'security: responds with 401 auth error' do
      get :current_level, assessment_id: assessment.id
      assert_response :unauthorized
    end

  end

end