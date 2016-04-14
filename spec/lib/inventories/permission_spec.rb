require 'spec_helper'

describe Inventories::Permission do
  describe "#role" do
    context "as participant" do
      let(:inventory) { FactoryGirl.create(:inventory, :with_participants) }
      let(:participant_user) { inventory.participants.first.user }
      subject { Inventories::Permission.new(inventory: inventory, user: participant_user) }

      it { expect(subject.role).to eq 'participant' }
    end

    context "as facilitator" do
      let(:inventory) { FactoryGirl.create(:inventory, :with_facilitators) }
      let(:facilitator_user) { inventory.facilitators.first.user }
      subject { Inventories::Permission.new(inventory: inventory, user: facilitator_user) }

      it { expect(subject.role).to eq 'facilitator' }
    end

    describe "role=" do
      context "as new user" do
        let(:inventory) { FactoryGirl.create(:inventory) }
        let(:user) { FactoryGirl.create(:user) }
        subject { Inventories::Permission.new(inventory: inventory, user: user) }

        before(:each) do
          subject.role= 'facilitator'
        end

        it { expect(subject.role).to eq 'facilitator' }
      end

      context "as existing member" do
        let(:inventory) { FactoryGirl.create(:inventory, :with_participants) }
        let(:existing_user) { inventory.participants.first.user }
        subject { Inventories::Permission.new(inventory: inventory, user: existing_user) }

        before(:each) do
          allow(InventoryAccessGrantedNotificationWorker).to receive(:perform_async) 
          subject.role= 'facilitator'
        end

        it { expect(subject.role).to eq 'facilitator' }
        it { expect(InventoryAccessGrantedNotificationWorker).to have_received(:perform_async).with(inventory.id, existing_user.id, 'facilitator') }
      end
    end
  end

  describe '#access_request' do
    context "for a user that has requested access" do
      let(:access_request) { FactoryGirl.create(:inventory_access_request, :as_facilitator) }
      let(:inventory) { access_request.inventory }
      let(:user) { access_request.user }

      subject { Inventories::Permission.new(inventory: inventory, user: user) }

      it 'retrieves the access request' do
        expect(subject.access_request).to eq access_request
      end
    end

    context "for a user that has not requested access" do
      let(:access_request) { FactoryGirl.create(:inventory_access_request, :as_facilitator) }
      let(:inventory) { access_request.inventory }
      let(:user) { FactoryGirl.create(:user) }

      subject { Inventories::Permission.new(inventory: inventory, user: user) }

      it { expect(subject.access_request).to be_nil }
    end
  end

  describe '#accept' do
    let(:access_request) { FactoryGirl.create(:inventory_access_request, :as_facilitator) }
    let(:inventory) { access_request.inventory }
    let(:user) { access_request.user }

    subject { Inventories::Permission.new(inventory: inventory, user: user) }

    before(:each) do
      allow(InventoryAccessGrantedNotificationWorker).to receive(:perform_async).once
      subject.accept
    end

    it { expect(subject.access_request).to be_nil }
    it { expect(subject.role).to eq 'facilitator' }
    it { expect(InventoryAccessGrantedNotificationWorker).to have_received(:perform_async).with(inventory.id, user.id, 'facilitator') }
  end

  describe '#deny' do
    let(:access_request) { FactoryGirl.create(:inventory_access_request, :as_facilitator) }
    let(:inventory) { access_request.inventory }
    let(:user) { access_request.user }

    subject { Inventories::Permission.new(inventory: inventory, user: user) }

    before(:each) do
      subject.deny
    end

    it { expect(subject.access_request).to be_nil }
    it { expect(subject.role).to be_nil }
  end

  describe '#revoke' do
    let(:inventory) { FactoryGirl.create(:inventory, :with_participants) }
    let(:participant) { inventory.participants.first }
    let(:user) { participant.user }

    subject { Inventories::Permission.new(inventory: inventory, user: user) }

    before(:each) do
      subject.revoke
    end

    it { expect(subject.role).to be_nil }
  end

  describe '#available_permissions' do
    context 'as participant' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_participants) }
      let(:user) { inventory.participants.first.user }

      subject { Inventories::Permission.new(inventory: inventory, user: user) }

      it { expect(subject.available_roles).not_to include 'participant' }
    end

    context 'as facilitator' do
      let(:inventory) { FactoryGirl.create(:inventory, :with_facilitators) }
      let(:user) { inventory.members.first.user }

      subject { Inventories::Permission.new(inventory: inventory, user: user) }

      it { expect(subject.available_roles).not_to include 'facilitator' }
    end
  end

  describe '#request_access' do
    context 'as participant' do
      let(:inventory) { FactoryGirl.create(:inventory) }
      let(:user) { FactoryGirl.create(:user) }

      subject { Inventories::Permission.new(inventory: inventory, user: user) }

      before(:each) do
        allow(InventoryAccessRequestNotificationWorker).to receive(:perform_async) 
        subject.request_access(role: 'participant')
      end

      it { expect(subject.access_request).not_to be_nil }
      it { expect(subject.access_request.role).to eq 'participant' }
      it { expect(InventoryAccessRequestNotificationWorker).to have_received(:perform_async).with(subject.access_request.id) }
    end

    context 'as facilitator' do
      let(:inventory) { FactoryGirl.create(:inventory) }
      let(:user) { FactoryGirl.create(:user) }

      subject { Inventories::Permission.new(inventory: inventory, user: user) }

      before(:each) do
        subject.request_access(role: 'facilitator')
      end

      it { expect(subject.access_request).not_to be_nil }
      it { expect(subject.access_request.role).to eq 'facilitator' }
    end
  end
end
