require 'spec_helper'

describe AnalysisAuthorizer do

  subject { analysis }

  let(:member_user) {
    user = create(:user, :with_district)
    create(:inventory_member, user: user, inventory: inventory)
    user
  }

  let(:participant_user) {
    user = create(:user, :with_district)
    create(:inventory_member, :as_participant, user: user, inventory: inventory)
    user
  }

  let(:facilitator_user) {
    user = create(:user, :with_district)
    create(:inventory_member, :as_facilitator, user: user, inventory: inventory)
    user
  }

  let(:other_user) {
    create(:user, :with_district)
  }

  let(:inventory) {
    create(:inventory, :with_product_entries)
  }

  let(:analysis) {
    create(:analysis, inventory: inventory)
  }

  context 'when reading an analysis' do
    context 'when the user is the inventory owner' do
      it { is_expected.to be_readable_by(inventory.owner) }
    end

    context 'when the user is an inventory member' do
      it { is_expected.to_not be_readable_by(member_user) }
    end


    context 'when the user is an inventory participant' do
      it { is_expected.to be_readable_by(participant_user) }
    end

    context 'when the user is an inventory facilitator' do
      it { is_expected.to be_readable_by(facilitator_user) }
    end

    context 'when the user is not an inventory member, participant or facilitator' do
      it { is_expected.to_not be_readable_by(other_user) }
    end
  end

  context 'when creating an analysis' do
    context 'when the user is the inventory owner' do
      it { is_expected.to be_creatable_by(inventory.owner) }
    end

    context 'when the user is an inventory member' do
      it { is_expected.to_not be_creatable_by(member_user) }
    end

    context 'when the user is an inventory participant' do
      it { is_expected.to be_creatable_by(participant_user) }
    end

    context 'when the user is an inventory facilitator' do
      it { is_expected.to be_creatable_by(facilitator_user) }
    end

    context 'when the user is not an inventory member, participant or facilitator' do
      it { is_expected.to_not be_creatable_by(other_user) }
    end
  end

  context 'when updating an analysis' do
    context 'when the user is the inventory owner' do
      it { is_expected.to be_updatable_by(inventory.owner) }
    end

    context 'when the user is an inventory member' do
      it { is_expected.to_not be_updatable_by(member_user) }
    end

    context 'when the user is an inventory participant' do
      it { is_expected.to be_updatable_by(participant_user) }
    end

    context 'when the user is an inventory facilitator' do
      it { is_expected.to be_updatable_by(facilitator_user) }
    end

    context 'when the user is not an inventory member, participant or facilitator' do
      it { is_expected.to_not be_updatable_by(other_user) }
    end
  end

  context 'when deleting an analysis' do
    context 'when the user is the inventory owner' do
      it { is_expected.to be_deletable_by(inventory.owner) }
    end

    context 'when the user is an inventory member' do
      it { is_expected.to_not be_deletable_by(member_user) }
    end

    context 'when the user is an inventory participant' do
      it { is_expected.to be_deletable_by(participant_user) }
    end

    context 'when the user is an inventory facilitator' do
      it { is_expected.to be_deletable_by(facilitator_user) }
    end

    context 'when the user is not an inventory member, participant or facilitator' do
      it { is_expected.to_not be_deletable_by(other_user) }
    end
  end
end
