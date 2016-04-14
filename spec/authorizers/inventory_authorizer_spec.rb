require 'spec_helper'

describe InventoryAuthorizer do
  describe '#creatable_by?' do
    context 'anyone' do
      let(:user) { FactoryGirl.create(:user) }
      let(:inventory) { FactoryGirl.create(:inventory) }
      subject { inventory.authorizer }

      it('is allowed') { is_expected.to be_creatable_by(user) }
    end
  end

  describe '#updatable_by?' do
    context 'not member' do
      let(:user) { FactoryGirl.create(:user) }
      let(:inventory) { FactoryGirl.create(:inventory) }
      subject { inventory.authorizer }

      it('is not be allowed') { is_expected.not_to be_updatable_by(user) }
    end

    context 'facilitator' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_facilitators) }
      let(:facilitator_user) { inventory.facilitators.first.user }
      subject { inventory.authorizer }

      it('is allowed') { is_expected.to be_updatable_by(facilitator_user) }
    end

    context 'owner' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_facilitators) }
      let(:owner_user) { inventory.owner }
      subject { inventory.authorizer }

      it('is allowed') { is_expected.to be_updatable_by(owner_user) }
    end
  end

  describe '#readable_by?' do
    context 'not member' do
      let(:user) { FactoryGirl.create(:user) }
      let(:inventory) { FactoryGirl.create(:inventory) }
      subject { inventory.authorizer }

      it('is not be allowed') { is_expected.not_to be_readable_by(user) }
    end

    context 'member' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_members) }
      let(:member_user) { inventory.members.first.user }
      subject { inventory.authorizer }

      it('is allowed') { is_expected.to be_readable_by(member_user) }
    end
  end

  describe '#deletable_by?' do
    context 'not member' do
      let(:user) { FactoryGirl.create(:user) }
      let(:inventory) { FactoryGirl.create(:inventory) }
      subject { inventory.authorizer }

      it('is not be allowed') { is_expected.not_to be_deletable_by(user) }
    end

    context 'facilitator' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_facilitators) }
      let(:facilitator_user) { inventory.facilitators.first.user }
      subject { inventory.authorizer }

      it('is allowed') { is_expected.to be_deletable_by(facilitator_user) }
    end

    context 'owner' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_facilitators) }
      let(:owner_user) { inventory.owner }
      subject { inventory.authorizer }

      it('is allowed') { is_expected.to be_deletable_by(owner_user) }
    end
  end
end

