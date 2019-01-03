require 'spec_helper'

describe V1::AnalysisResponsesController do

  describe 'POST #create' do
    context 'when unauthenticated' do
      before(:each) do
        post :create, params: { inventory_id: 100000, analysis_id: 100000 }
      end

      it 'rejects their request outright' do
        expect(response.status).to eq 302
      end
    end

    context 'when the user does not have the ability to create an analysis' do
      let(:user) {
        create(:user)
      }

      let(:inventory) {
        create(:inventory)
      }

      let(:analysis) {
        create(:analysis, inventory: inventory)
      }

      before(:each) do
        sign_in user
        post :create, params: { inventory_id: inventory.id, analysis_id: analysis.id }
      end

      it 'does not allow them to create the entity' do
        expect(response.status).to eq 403
      end
    end

    context 'when authorized to create an analysis' do
      let(:user) {
        create(:user)
      }

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

      before(:each) do
        sign_in user
        post :create, params: { inventory_id: inventory.id, analysis_id: analysis.id }
      end

      it 'creates the response entity' do
        expect(Response.where(responder_id: analysis.id, responder_type: 'Analysis').first).to_not be_nil
      end

      it 'uses the parent analysis\' rubric' do
        expect(Response.where(responder_id: analysis.id, responder_type: 'Analysis').first.rubric.id).to eq rubric.id
      end
    end
  end
end
