require 'spec_helper'

describe V1::InventoryParticipantsController do
  render_views

  describe '#create' do
    context 'logged-out user' do
      let(:inventory) { FactoryGirl.create(:inventory) }
      let(:user) { FactoryGirl.create(:user) }

      before(:each) do
        post :create, inventory_id: inventory.id, format: :json,
          user_id: user.id
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context 'logged-in user' do
      let(:me) { FactoryGirl.create(:user) }
      let(:district_user) { FactoryGirl.create(:user, :with_district) }
      let(:inventory) { FactoryGirl.create(:inventory, owner: me, district: district_user.districts.first) }

      before(:each) do
        sign_in me
        post :create,
          inventory_id: inventory.id,
          user_id: district_user.id,
          format: :json
      end

      it { expect(response).to have_http_status(:created) }
      it { expect(inventory.participants.where(user: district_user)).to exist }
    end
  end

  describe '#delete' do
    context 'logged-out user' do
      let(:inventory) { FactoryGirl.create(:inventory) }
      let(:user) { FactoryGirl.create(:user) }

      before(:each) do
        delete :destroy, inventory_id: inventory.id, format: :json,
          id: user.id
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context 'logged-in user' do
      let(:me) { FactoryGirl.create(:user) }
      let(:inventory) { FactoryGirl.create(:inventory, :with_participants, participants: 1, owner: me) }
      let(:member_user) { inventory.participants.first.user }

      before(:each) do
        sign_in me
        delete :destroy,
          inventory_id: inventory.id,
          id: member_user.id,
          format: :json
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(inventory.participants.where(user: member_user)).not_to exist }
    end
  end
end
