require 'spec_helper'

describe V1::InventoryInvitationsController do
  render_views

  describe '#create' do
    context 'without user' do
      let(:inventory) { FactoryGirl.create(:inventory) }

      before(:each) do
        sign_out :user
        post :create, inventory_id: inventory.id, format: :json
      end

      it 'requires logged in user' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'as non-facilitator' do
      let(:user) { FactoryGirl.create(:user) }
      let(:inventory) { FactoryGirl.create(:inventory) }

      before(:each) do
        sign_in user
        post :create, inventory_id: inventory.id, format: :json
      end

      it 'requires a facilitator to create a invite' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'as facilitator' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_facilitators) }
      let(:facilitator_user) { inventory.facilitators.first.user }
      let(:email) { 'john_doe@gmail.com' }

      context 'inviting user for second time' do
        let(:existing_invitation) { FactoryGirl.create(:inventory_invitation, inventory: inventory) }

        before(:each) do
          sign_in facilitator_user
          post :create,
            inventory_id: inventory.id,
            first_name: 'john',
            last_name: 'doe',
            email: existing_invitation.email,
            team_role: 'Finance',
            role: 'facilitator', format: :json
        end

        it 'returns error status code' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error message' do
          expect(json["errors"]["email"]).to include("User has already been invited")
        end
      end

      context 'inviting user' do
        let(:created_invitation) { InventoryInvitation.where(email: email).first }

        before(:each) do
          sign_in facilitator_user
          post :create,
            inventory_id: inventory.id,
            first_name: 'john',
            last_name: 'doe',
            email: email,
            team_role: 'Finance',
            role: 'facilitator', format: :json
        end

        it 'invitation gets created' do
          expect(created_invitation).not_to be_nil
        end
      end
    end
  end
end
