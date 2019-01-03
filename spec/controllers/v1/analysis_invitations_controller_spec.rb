require 'spec_helper'

describe V1::AnalysisInvitationsController do
  render_views

  describe '#create' do
    context 'without user' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_analysis) }
      let(:analysis) { inventory.analyses.first }

      before(:each) do
        sign_out :user
        post :create, params: {
          inventory_id: inventory.id, analysis_id: analysis
        }, as: :json
      end

      it 'requires logged in user' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with user' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_analysis) }
      let(:analysis) { inventory.analyses.first }
      let(:email) { 'john_doe@gmail.com' }

      context 'inviting user' do
        let(:created_invitation) { AnalysisInvitation.where(email: email).first }

        before(:each) do
          sign_in inventory.owner
          post :create, params: {
            inventory_id: inventory.id,
            analysis_id: analysis,
            first_name: 'john',
            last_name: 'doe',
            email: email,
            team_role: 'Finance',
            role: 'facilitator'
          }, as: :json
        end

        it 'invitation gets created' do
          expect(created_invitation).not_to be_nil
        end
      end

      context 'inviting user for second time' do
        let(:existing_invitation) { FactoryGirl.create(:analysis_invitation, analysis: analysis) }

        before(:each) do
          sign_in inventory.owner
          post :create, params: {
            inventory_id: inventory.id,
            analysis_id: analysis,
            first_name: 'john',
            last_name: 'doe',
            email: existing_invitation.email,
            team_role: 'Finance',
            role: 'facilitator'
          }, as: :json
        end

        it 'returns error status code' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error message' do
          expect(json["errors"]["email"]).to include("User has already been invited")
        end
      end
    end
  end
end
