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
      it 'responds successfully to GET#show' do
        sign_in @facilitator

        get :index, assessment_id: assessment.id
        assert_response :success 
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
        sign_in @facilitator2

        get :show, assessment_id: assessment.id, id: 1
        assert_response :success
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

end