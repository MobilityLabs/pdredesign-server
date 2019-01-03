require 'spec_helper'

describe V1::AnalysisConsensusController do
  render_views

  before(:each) do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  describe 'POST #create' do
    context 'when unauthenticated' do
      before(:each) do
        post :create, params: {  inventory_id: 8999, analysis_id: 9000 }
      end

      it 'returns unauthorized' do
        expect(response.status).to eq 401
      end
    end

    context 'when authenticated' do
      let(:user) {
        create(:user)
      }

      context 'when the entity does not exist' do
        let(:inventory) {
          create(:inventory, tool_members: create_list(:tool_member, 1, :as_facilitator, user: user))
        }

        let(:analysis_member) {
          analysis.facilitators.first
        }

        let(:analysis) {
          create(:analysis, :with_facilitators, inventory: inventory, rubric: create(:rubric, :as_analysis_rubric))
        }

        before(:each) do
          sign_in user
          post :create, params: { inventory_id: inventory.id, analysis_id: analysis.id }
        end

        it 'creates the entity' do
          expect(Response.where(responder: analysis, rubric: analysis.rubric).first).to_not be_nil
        end

        it 'renders the right templates' do
          expect(response).to render_template 'v1/analysis_consensus/create'
          expect(response).to render_template 'v1/responses/_response'
        end
      end

      context 'when the entity exists prior' do
        let(:inventory) {
          create(:inventory, tool_members: create_list(:tool_member, 1, :as_facilitator, user: user))
        }

        let(:analysis_member) {
          analysis.facilitators.first
        }

        let(:rubric) {
          create(:rubric, :as_analysis_rubric)
        }

        let(:analysis) {
          create(:analysis, :with_facilitators, inventory: inventory, rubric: rubric)
        }

        let!(:response) {
          create(:response, responder: analysis, rubric: rubric)
        }

        before(:each) do
          sign_in user
          post :create, params: { inventory_id: inventory.id, analysis_id: analysis.id }
        end

        it 'does not overwrite the entity' do
          expect(Response.where(responder: analysis, rubric: rubric).first).to eq response
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when unauthenticated' do
      before(:each) do
        get :show, params: { inventory_id: 8999, analysis_id: 9000, id: 9001 }
      end

      it 'returns unauthorized' do
        expect(response.status).to eq 401
      end
    end

    context 'when authenticated' do

      let(:user) {
        create(:user)
      }

      context 'when no response can be found' do
        let(:inventory) {
          create(:inventory, tool_members: create_list(:tool_member, 1, :as_facilitator, user: user))
        }

        let(:analysis_member) {
          analysis.facilitators.first
        }

        let(:analysis) {
          create(:analysis, :with_facilitators, inventory: inventory, rubric: create(:rubric, :as_analysis_rubric))
        }

        before(:each) do
          sign_in user
          get :show, params: { inventory_id: inventory.id, analysis_id: analysis.id, id: 9001 }
        end

        it 'returns a 404' do
          expect(response.status).to eq 404
        end
      end

      context 'when the response exists' do

        let(:inventory) {
          create(:inventory, tool_members: create_list(:tool_member, 1, :as_facilitator, user: user))
        }

        let(:analysis_member) {
          analysis.facilitators.first
        }

        let(:rubric) {
          create(:rubric, :as_analysis_rubric)
        }

        let(:analysis) {
          create(:analysis, :with_facilitators, inventory: inventory, rubric: rubric)
        }

        let(:preexisting_response) {
          create(:response, responder: analysis, rubric: rubric)
        }

        before(:each) do
          sign_in user
          get :show, params: { inventory_id: inventory.id, analysis_id: analysis.id, id: preexisting_response.id }
        end

        it 'renders the right JSON view' do
          expect(response).to render_template 'v1/analysis_consensus/show'
        end
      end
    end
  end

  describe 'PATCH #update' do
    context 'when unauthenticated' do
      before(:each) do
        patch :update, params: { inventory_id: 8999, analysis_id: 9000, id: 9001 }
      end

      it 'returns unauthorized' do
        expect(response.status).to eq 401
      end
    end

    context 'when authenticated' do
      let(:user) {
        create(:user)
      }

      context 'when the submit parameter is not passed' do
        let(:inventory) {
          create(:inventory, tool_members: create_list(:tool_member, 1, :as_facilitator, user: user))
        }

        let(:analysis_member) {
          analysis.facilitators.first
        }

        let(:rubric) {
          create(:rubric, :as_analysis_rubric)
        }

        let(:analysis) {
          create(:analysis, :with_facilitators, inventory: inventory, rubric: rubric)
        }

        let(:preexisting_response) {
          create(:response, responder: analysis, rubric: rubric)
        }

        before(:each) do
          sign_in user
          patch :update, params: { inventory_id: inventory.id, analysis_id: analysis.id, id: preexisting_response.id, submit: nil }
          preexisting_response.reload
        end

        it 'does not update the response\'s submitted_at field' do
          expect(preexisting_response.submitted_at).to be_nil
        end
      end

      context 'when the submit parameter is passed' do
        let(:inventory) {
          create(:inventory, tool_members: create_list(:tool_member, 1, :as_facilitator, user: user))
        }

        let(:analysis_member) {
          analysis.facilitators.first
        }

        let(:rubric) {
          create(:rubric, :as_analysis_rubric)
        }

        let(:analysis) {
          create(:analysis, :with_facilitators, inventory: inventory, rubric: rubric)
        }

        let(:preexisting_response) {
          create(:response, responder: analysis, rubric: rubric)
        }

        before(:each) do
          sign_in user
          patch :update, params: { inventory_id: inventory.id, analysis_id: analysis.id, id: preexisting_response.id, submit: 'true' }
          preexisting_response.reload
        end

        it 'updates the response\'s submitted_at field' do
          expect(preexisting_response.submitted_at).not_to be_nil
        end
      end
    end
  end
end
