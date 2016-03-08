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

=begin
  let(:assessment) {
    @assessment_with_participants
  }

  let(:user) {
    FactoryGirl.create(:user)
  }

  before(:each) do
    create_magic_assessments
  end

  describe '#available_permissions' do
    it 'contains the correct available permissions' do
      expect(Assessments::Permission.available_permissions).to eq([:facilitator, :participant])
    end
  end

  context 'when requesting access to an assessment' do

    before(:each) do
      Assessments::Permission.request_access(
          user: user,
          roles: 'facilitator',
          assessment_id: assessment.id)
    end

    it 'creates the access request object' do
      expect(AccessRequest.find_by(assessment_id: assessment.id, user_id: user.id)).not_to be_nil
    end
  end

  context 'when determining the possible levels for a user' do

    let(:assessment_permission) {
      Assessments::Permission.new(assessment)
    }

    before(:each) do
      participant = Participant.new(user: user, assessment: assessment)
      participant.save!
    end

    it 'returns the correct permission levels for a user' do
      expect(assessment_permission.possible_roles_permissions(user)).to eq([:facilitator])
    end
  end

  context 'permission level' do

    let(:assessment_permission) {
      Assessments::Permission.new(assessment)
    }

    context 'when requesting access as a facilitator' do
      let!(:request_access) {
        Application.request_access_to_assessment(assessment: assessment, user: user, roles: ['facilitator'])
      }

      it 'accepts a facilitator request via asynchronous call' do
        expect(AccessGrantedNotificationWorker).to receive(:perform_async)
        assessment_permission.accept_permission_requested(user)
        expect(assessment.facilitator?(user)).to be true
      end

      it "returns the user's permission level" do
        assessment_permission.accept_permission_requested(user)
        expect(assessment_permission.get_level(user)).to eq(:facilitator)
      end

      it 'should respond with the list of users requesting access' do
        expect(assessment_permission.requested).to include(request_access)
      end
    end

    context 'when requesting access as a participant' do
      let(:new_user) {
        FactoryGirl.create(:user)
      }

      before(:each) do
        Application.request_access_to_assessment(
            assessment: assessment, user: new_user, roles: ['participant'])
      end

      it 'accepts a participant request' do
        assessment_permission.accept_permission_requested(new_user)
        expect(assessment.participant?(new_user)).to be true
      end
    end

    it 'adds a permission level to user' do
      assessment_permission.add_level(user, 'network_partner')
      expect(assessment.network_partner?(user)).to be true
    end


    it 'updates the permission level' do
      assessment.facilitators << @facilitator
      assessment_permission.update_level(@facilitator, 'viewer')

      expect(assessment.facilitator?(@facilitator)).to be false
      expect(assessment_permission.get_level(@facilitator)).to eq(:viewer)
    end

    it 'updates only when the new level is different' do
      assessment.facilitators << @facilitator
      expect(AccessGrantedNotificationWorker).not_to receive(:perform_async)

      assessment_permission.update_level(@facilitator, 'facilitator')
      expect(assessment.facilitator?(@facilitator)).to eq(true)
    end

    it 'does not update the owner' do
      owner = assessment.user

      assessment_permission.update_level(assessment.user, 'viewer')

      expect(assessment.owner?(owner)).to be true
      expect(assessment.viewer?(owner)).to be false
    end
  end

  context 'when denying a permission request' do
    let(:assessment_permission) {
      Assessments::Permission.new(assessment)
    }

    before(:each) do
      Application.request_access_to_assessment(assessment: assessment, user: user, roles: ['facilitator'])
      assessment_permission.deny(user)
    end

    it 'deletes the request' do
      expect(assessment_permission.get_access_request(user)).to be_nil
    end
  end

  context 'participants' do
    it 'does not send notification for permission granted when is participant' do
      Application.request_access_to_assessment(assessment: assessment, user: user, roles: ['participant'])
      expect(AccessGrantedNotificationWorker).not_to receive(:perform_async)

      assessment_permission = Assessments::Permission.new(assessment)
      assessment_permission.accept_permission_requested(user)
    end
  end

  context 'notification emails' do

    let(:assessment_permission) {
      Assessments::Permission.new(assessment)
    }

    let(:access_granted_notification_worker) {
      class_spy(AccessGrantedNotificationWorker)
    }

    context 'when the role is a facilitator' do
      before(:each) do
        Application.request_access_to_assessment(assessment: assessment, user: user, roles: ['facilitator'])
        allow(AccessGrantedNotificationWorker).to receive(:perform_async)
      end

      it 'notifies the user by email' do
        assessment_permission.accept_permission_requested(user)
        expect(AccessGrantedNotificationWorker).to have_received(:perform_async)
      end

      it 'sends an email when the facilitator permission level is added' do
        assessment_permission.add_level(user, 'facilitator')
        expect(AccessGrantedNotificationWorker).to have_received(:perform_async)
      end
    end

    context 'when the role is a participant' do
      before(:each) do
        Application.request_access_to_assessment(assessment: assessment, user: user, roles: [:participant])
        allow(AccessGrantedNotificationWorker).to receive(:perform_async)
      end

      it 'does not notify the user by email' do
        assessment_permission.accept_permission_requested(user)
        expect(AccessGrantedNotificationWorker).to_not have_received(:perform_async)
      end
    end
  end
=end
end
