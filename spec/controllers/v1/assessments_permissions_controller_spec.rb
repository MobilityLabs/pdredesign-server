require 'spec_helper'

describe V1::AssessmentsPermissionsController do
  render_views

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe '#index' do
    context 'respond to GET#index' do
      it 'responds successfully to GET#show' do
        get :index, assessment_id: 4
        assert_response :success 
      end
    end
  end

  describe '#show' do
    context 'respond to GET#show' do
      it 'responds successfully to GET#show' do
        get :show, assessment_id: 4, id: 1
        assert_response :success
      end
    end
  end

  describe '#update' do
    context 'respond to PUT#update' do
      it 'responds successfully to PUT#update' do
        put :update, assessment_id: 4, id: 1
        assert_response :success
      end
    end
  end

end