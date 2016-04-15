# == Schema Information
#
# Table name: inventories
#
#  id          :integer          not null, primary key
#  name        :text             not null
#  deadline    :datetime         not null
#  district_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :integer
#

require 'spec_helper'

describe Inventory do
  it { is_expected.to have_many(:product_entries) }
  it { is_expected.to have_many(:data_entries) }
  it { is_expected.to have_many(:access_requests) }
  it { is_expected.to have_many(:facilitators) }
  it { is_expected.to have_many(:participants) }
  it { is_expected.to have_many(:invitations) }
  it { is_expected.to belong_to(:district) }
  it { is_expected.to belong_to(:owner) }

  it { is_expected.to accept_nested_attributes_for(:product_entries) }
  it { is_expected.to accept_nested_attributes_for(:data_entries) }

  it { is_expected.to validate_length_of(:name).is_at_least(1) }
  it { is_expected.to validate_length_of(:name).is_at_most(255) }
  it { is_expected.to validate_presence_of(:deadline) }

  describe '#send_invites' do
    let(:inventory) { FactoryGirl.create(:inventory, :with_members, members: 3) }
    let(:uninvited_members) { inventory.members }
    let!(:invitations) {
      uninvited_members.map do |member|
        FactoryGirl.create(:inventory_invitation, user: member.user, inventory: member.inventory)
      end
    }

    before(:each) do
      allow(InventoryInvitationNotificationWorker).to receive(:perform_async)
      inventory.send_invites
    end

    it 'send invitations' do
      expect(InventoryInvitationNotificationWorker).to have_received(:perform_async).at_least(uninvited_members.count).times
    end
  end

  context 'when saving a record in the past' do
    subject {
      Inventory.new
    }

    before(:each) do
      subject.deadline = 1.minute.ago
      subject.owner = create(:user)
      subject.name = 'Foo'
      subject.save
    end

    it 'has only one error' do
      expect(subject.errors.size).to eq 1
    end

    it 'gives back the correct error message' do
      expect(subject.errors[:deadline][0]).to eq 'cannot be in the past'
    end

  end

  describe '#save' do
    let(:owner) { FactoryGirl.create(:user) }
    subject { FactoryGirl.create(:inventory, owner: owner) }

    it { expect(subject.new_record?).to be false }
    it 'add owner as facilitator' do
      expect(subject.facilitators.where(user: owner)).to exist
    end
  end

  describe '#owner?' do
    context 'owner is current user' do
      let(:inventory) { FactoryGirl.create(:inventory) }

      it do
        expect(inventory.owner?(user: inventory.owner)).to be true
      end
    end

    context 'owner is a different user' do
      let(:inventory) { FactoryGirl.create(:inventory) }
      let(:user) { FactoryGirl.create(:user) }

      it do
        expect(inventory.owner?(user: user)).to be false
      end
    end
  end

  describe '#member?' do
    context 'user is member' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_members) }
      let(:user) { inventory.members.first.user }

      it do
        expect(inventory.member?(user: user)).to be true
      end
    end

    context 'user is not member' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_members) }
      let(:user) { FactoryGirl.create(:user) }

      it do
        expect(inventory.member?(user: user)).to be false
      end
    end
  end
end
