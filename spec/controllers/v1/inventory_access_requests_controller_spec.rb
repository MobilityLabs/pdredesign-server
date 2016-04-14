require  'spec_helper'

describe V1::InventoryAccessRequestsController do
  render_views

  describe '#index' do
    context 'as signed in user' do
      let(:user) { FactoryGirl.create(:user) }
      let(:inventory) { FactoryGirl.create(:inventory) }
      let!(:access_requests) { FactoryGirl.create_list(:inventory_access_request, 2, :as_facilitator, inventory: inventory) }

      before(:each) do 
        sign_in user
        get :index, inventory_id: inventory.id, format: :json
      end

      it { expect(response).to have_http_status(:success) }

      it  do
        expect(response.body).to match(/requested_permission_level/)
      end
    end
  end

  describe '#create' do
    context 'as signed in user' do
      let(:user) { FactoryGirl.create(:user) }

      before(:each) do 
        sign_in user
      end

      context 'with valid request params' do
        let(:inventory) { FactoryGirl.create(:inventory) }
        let(:access_request) { InventoryAccessRequest.find(json["id"]) }

        before(:each) do 
          post :create,
            inventory_id: inventory.id,
            role: 'facilitator', format: :json
        end

        it { expect(response).to have_http_status(:success) }

        it 'creates a request record' do
          expect(access_request).not_to be_nil
        end

        it { expect(access_request.user_id).to eq user.id }
        it { expect(access_request.role).to eq 'facilitator' }
        it { expect(access_request.inventory_id).to eq inventory.id }
      end

      context 'without role' do
        let(:inventory) { FactoryGirl.create(:inventory) }

        before(:each) do 
          post :create, inventory_id: inventory.id, format: :json
        end

        it { expect(response).to have_http_status(:unprocessable_entity) }

        it { expect(json["errors"]).not_to be_empty }
      end
    end
  end

  describe '#update' do
    context 'as signed-in user' do
      let(:user) { FactoryGirl.create(:user) }

      before(:each) do
        sign_in user
      end

      context 'on non-existing request' do
        let(:inventory) { FactoryGirl.create(:inventory) }

        before(:each) do
          patch :update,
            inventory_id: inventory.id,
            id: 99999999,
            status: 'denied', format: :json
        end

        it { expect(response).to have_http_status(:not_found) }
      end

      context 'denying access' do
        let(:inventory) { FactoryGirl.create(:inventory) }
        let(:access_request) { FactoryGirl.create(:inventory_access_request, :as_participant, inventory: inventory) }

        before(:each) do
          patch :update,
            inventory_id: inventory.id,
            id: access_request.id,
            status: 'denied', format: :json
        end

        it { expect(response).to have_http_status(:success) }

        it 'destroys access request' do
          expect(InventoryAccessRequest.where(id: access_request.id)).not_to exist
        end

        it 'does not assign roles to user' do
          expect(Inventories::Permission.new(inventory: inventory, user: access_request.user).role).to be_blank
        end
      end

      context 'accepting access' do
        let(:inventory) { FactoryGirl.create(:inventory) }
        let(:access_request) { FactoryGirl.create(:inventory_access_request, :as_participant, inventory: inventory) }

        before(:each) do 
          patch :update,
            inventory_id: inventory.id,
            id: access_request.id,
            status: 'accepted', format: :json
        end

        it { expect(response).to have_http_status(:success) }

        it 'destroys access request' do
          expect(InventoryAccessRequest.where(id: access_request.id)).not_to exist
        end

        it 'creates member with requested role' do
          expect(Inventories::Permission.new(inventory: inventory, user: access_request.user).role).to eq 'participant'
        end
      end
    end
  end
end
