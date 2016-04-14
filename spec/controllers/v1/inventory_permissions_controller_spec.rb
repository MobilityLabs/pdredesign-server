require 'spec_helper'

describe V1::InventoryPermissionsController do
  render_views

  describe '#show' do
    context 'logged-out user' do
      let(:inventory) { FactoryGirl.create(:inventory) }
      before(:each) do
        get :show, inventory_id: inventory.id, format: :json
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context 'logged-in user' do
      let(:user) { FactoryGirl.create(:user) }
      let(:inventory) { FactoryGirl.create(:inventory, :with_participants, :with_facilitators, facilitators: 2, participants: 2) }
      let(:participant_users) { inventory.participants.map(&:user) }
      let(:facilitator_user) { inventory.facilitators.map(&:user) }

      before(:each) do
        sign_in user
        get :show, inventory_id: inventory.id, format: :json
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(json).to have_at_least(4).items }

      it 'contain all facilitators' do 
        expect((json.select {|permission| permission['current_permission_level']['role'] == 'facilitator'}).map {|p| p['id']}).to have_at_least(2).items
      end

      it 'contain all participants' do 
        expect((json.select {|permission| permission['current_permission_level']['role'] == 'participant'}).map {|p| p['id']}).to have_at_least(2).items
      end
    end
  end

  describe '#update' do
    context 'logged-out user' do
      let(:inventory) { FactoryGirl.create(:inventory) }
      before(:each) do
        post :update, inventory_id: inventory.id, format: :json
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context 'logged-in user' do
      let(:user) { FactoryGirl.create(:user) }
      let(:inventory) { FactoryGirl.create(:inventory, :with_participants, participants: 2) }
      let(:original_participant_users) { inventory.participants.map(&:user) }
      let(:original_participant_emails) { original_participant_users.map(&:email) }

      before(:each) do
        sign_in user
        post :update, inventory_id: inventory.id, format: :json,
          permissions: original_participant_emails.map { |email| {email: email, role: 'facilitator'} }
      end

      it { expect(response).to have_http_status(:success) }

      it 'changed all roles' do 
        expect(inventory.facilitators.map(&:user).map(&:email)).to include *original_participant_emails
      end
    end
  end
end
