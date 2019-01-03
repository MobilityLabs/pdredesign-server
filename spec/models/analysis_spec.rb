# == Schema Information
#
# Table name: analyses
#
#  id              :integer          not null, primary key
#  name            :text
#  deadline        :datetime
#  inventory_id    :integer
#  created_at      :datetime
#  updated_at      :datetime
#  message         :text
#  assigned_at     :datetime
#  rubric_id       :integer
#  owner_id        :integer
#  report_takeaway :text
#  share_token     :string
#

require 'spec_helper'
require 'support/message_migration_concern_shared_example'

describe Analysis do
  it_behaves_like 'a tool which adds initial messages', described_class.to_s.downcase

  describe 'validations' do
    it { is_expected.to belong_to(:inventory) }
    it { is_expected.to have_one(:response) }
    it { is_expected.to belong_to(:owner) }

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :deadline }
    it { is_expected.to validate_presence_of :inventory }
    it { is_expected.to validate_presence_of :rubric }
    it { is_expected.to validate_presence_of :owner }

    context ':assigned_at' do
      before do
        @analysis = Analysis.new(assigned_at: Time.now)
      end

      it 'requires :due_date when assigned_at is present' do
        expect(@analysis.valid?).to eq(false)
        expect(@analysis.errors[:message])
            .to include("can\'t be blank")
      end
    end

    context ':assigned_at' do
      before do
        @analysis = Analysis.new(assigned_at: Time.now)
      end

      it 'requires :due_date when assigned_at is present' do
        expect(@analysis.valid?).to eq(false)
        expect(@analysis.errors[:message])
            .to include("can't be blank")

        @analysis.assigned_at = nil
        @analysis.valid?
        expect(@analysis.errors[:message])
            .to eq([])
      end
    end
  end

  describe 'after the entity is created' do
    context 'when the user creating the analysis is the owner of its parent inventory' do
      let(:owner) {
        create(:user)
      }

      let(:inventory) {
        create(:inventory, :with_participants, :with_facilitators, participants: 2, facilitators: 2, owner: owner)
      }

      let(:analysis) {
        create(:analysis, inventory: inventory, owner: owner)
      }

      it {
        expect(analysis.owner).to equal owner
      }

      it 'does not register the owner as a particpant' do
        expect(analysis.participants.map(&:user).include?(owner)).to be false
      end

      it 'registers the owner as a facilitator' do
        expect(analysis.facilitators.map(&:user).include?(owner)).to be true
      end
    end

    context 'when the user creating the analysis is a facilitator of its parent inventory' do

      let(:owner) {
        inventory.facilitators.sample.user
      }

      let(:inventory) {
        create(:inventory, :with_participants, :with_facilitators, participants: 2, facilitators: 2)
      }

      let(:analysis) {
        create(:analysis, inventory: inventory, owner: owner)
      }

      it {
        expect(analysis.owner).to equal owner
      }

      it 'copies the user across as a facilitator' do
        expect(analysis.facilitators.map(&:user).include?(owner)).to be true
      end

      it 'adds the owner of the original inventory as a facilitator' do
        expect(analysis.facilitators.map(&:user).include?(inventory.owner)).to be true
      end
    end

    context 'when the user creating the analysis is a participant of its parent inventory' do
      let(:owner) {
        inventory.participants.sample.user
      }

      let(:inventory) {
        create(:inventory, :with_participants, :with_facilitators, participants: 2, facilitators: 2)
      }

      let(:analysis) {
        create(:analysis, inventory: inventory, owner: owner)
      }

      it {
        expect(analysis.owner).to equal owner
      }

      it 'does not copy the user across as a participant' do
        expect(analysis.participants.map(&:user).include?(owner)).to be false
      end

      it 'adds the owner of the original inventory as a facilitator' do
        expect(analysis.facilitators.map(&:user).include?(inventory.owner)).to be true
      end

      it 'adds the creator as a facilitator' do
        expect(analysis.facilitators.map(&:user).include?(owner)).to be true
      end
    end
  end

  describe 'after the entity is saved' do
    context 'when participants are added to the analysis' do
      # Inventory has one facilitator - owner
      let(:inventory) {
        create(:inventory, :with_participants, participants: 5)
      }

      # Analysis has 3 facilitators
      let(:facilitators) {
        create_list(:tool_member, 2, :as_facilitator, tool: analysis)
      }


      let!(:analysis) {
        create(:analysis, :with_participants, inventory: inventory)
      }

      before(:each) do
        inventory.reload
      end

      it 'copies the participants over as participants on the inventory' do
        expect(inventory.participants.map(&:user).map(&:id) & analysis.participants.map(&:user).map(&:id))
            .to match_array(analysis.participants.map(&:user).map(&:id))
      end

      it 'copies the facilitators over as participants on the inventory' do
        expect(inventory.participants.map(&:user).map(&:id) & (analysis.facilitators.map(&:user).map(&:id) - inventory.facilitators.map(&:user).map(&:id)))
            .to match_array(analysis.facilitators.map(&:user).map(&:id) - inventory.facilitators.map(&:user).map(&:id))
      end
    end

    context "when only the parent inventory's participants exist" do
      # Inventory has six facilitators including owner, and ten participants
      let!(:inventory) {
        create(:inventory, :with_participants, :with_facilitators, participants: 10, facilitators: 5)
      }

      let!(:analysis) {
        build(:analysis, inventory: inventory)
      }

      before(:each) do
        expect(inventory.participants.size).to eq 10
        expect(inventory.facilitators.size).to eq 6
        analysis.save!
        inventory.reload
      end

      it {
        expect(inventory.participants.size).to eq 11
      }

      it 'only copies over the owner of the analysis as a participant of the parent inventory' do
        expect(inventory.participants.map(&:user).map(&:id) & [analysis.owner.id])
            .to match_array([analysis.owner.id])
      end
    end

    context 'on repeated saves' do
      # Inventory has 2 participants and the owner as a facilitator
      let!(:inventory) {
        create(:inventory, :with_participants, participants: 2)
      }

      let!(:analysis) {
        build(:analysis, inventory: inventory)
      }

      before(:each) do
        expect(inventory.participants.size).to eq 2
        analysis.save!
        inventory.reload
        expect(inventory.participants.size).to eq 3
        analysis.save!
        inventory.reload
      end

      it {
        expect(inventory.participants.size).to eq 3
      }
    end
  end
end
