require 'spec_helper'

describe V1::SharedPrioritiesController do
  render_views

  let(:assessment) { FactoryGirl.create :assessment }

  describe '#index' do
    context 'with valid token' do
      let(:token) { assessment.share_token }

      context do
        let!(:priority_instance) do
          instance = instance_double(Assessments::Priority)
          allow(instance).to receive(:categories).and_return([])
          instance
        end

        let!(:priority_class) do
          klass = class_double(Assessments::Priority).as_stubbed_const
          expect(klass).to receive(:new).with(assessment).and_return(priority_instance)
          klass
        end

        it 'fetches categories using assessment priority' do 
          get :index, shared_token: token, format: :json
        end
      end

      it do
        get :index, shared_token: token, format: :json
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid token' do
      let(:token) { 'foo-bar-invalid' }

      it do
        get :index, shared_token: token, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

