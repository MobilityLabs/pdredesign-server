require 'spec_helper'

describe Inventories::MemberFromInvite do
  describe '#execute' do
    context 'inviting existing network partner as participant' do
      let(:inventory) { FactoryGirl.create(:inventory) }
      let(:existing_user) { FactoryGirl.create(:user, :with_network_partner_role, :with_district) }
      let!(:original_user_district) { existing_user.districts.first }
      let(:invitation) { FactoryGirl.create(:inventory_invitation, :as_participant, inventory_id: inventory.id ,email: existing_user.email) }

      before(:each) do
         Inventories::MemberFromInvite.new(invitation).execute
         existing_user.reload
      end

      it 'overrides the role to be facilitator' do
        expect(inventory.facilitator?(user: existing_user)).to be true
      end

      it 'sets user district' do
        expect(existing_user.district_ids).to include inventory.district_id
      end

      it 'does not overrides existing districts' do
        expect(existing_user.district_ids).to include original_user_district.id
      end

      it 'sets user team_role' do
        expect(existing_user.team_role).to eq invitation.team_role
      end
    end

    context 'inviting non network partner as participant' do
      let(:inventory) { FactoryGirl.create(:inventory) }
      let(:existing_user) { FactoryGirl.create(:user, :without_role) }
      let(:invitation) { FactoryGirl.create(:inventory_invitation, :as_participant, inventory: inventory, email: existing_user.email) }

      before(:each) do
        Inventories::MemberFromInvite.new(invitation).execute
      end

      it 'adds user as participant' do
        expect(inventory.participant?(user: existing_user)).to be true
      end
    end

    context 'inviting non-existent user ignoring email case' do
      let(:inventory) { FactoryGirl.create(:inventory) }
      let(:invitation) { FactoryGirl.create(:inventory_invitation, :as_participant, inventory: inventory, email: 'John_Doe@example.com') }
      let(:user) { User.find_by(email: 'john_doe@example.com') }

      before(:each) do
         Inventories::MemberFromInvite.new(invitation).execute
      end

      it 'creates user' do
        expect(user).to_not be_nil
      end

      it 'sets user district' do
        expect(user.district_ids).to include inventory.district_id
      end

      it 'sets user team_role' do
        expect(user.team_role).to eq invitation.team_role
      end

      it 'updates invitation with created user' do
        expect(invitation.user_id).to eq user.id
      end
    end
  end
end
