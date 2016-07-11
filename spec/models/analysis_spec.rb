# == Schema Information
#
# Table name: analyses
#
#  id             :integer          not null, primary key
#  name           :text
#  deadline       :datetime
#  inventory_id   :integer
#  created_at     :datetime
#  updated_at     :datetime
#  message        :text
#  assigned_at    :datetime
#  rubric_id      :integer
#  owner_id       :integer
#  report_takeway :text
#

require 'spec_helper'

describe Analysis do
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
          .to include("can\'t be blank")

        @analysis.assigned_at = nil
        @analysis.valid?
        expect(@analysis.errors[:message])
          .to eq([])
      end
    end
  end

  describe '#save' do
    subject { FactoryGirl.create(:analysis) }

    it { expect(subject.new_record?).to be false }
  end

  describe '#create' do

    context 'when user creating new analysis is the owner of its parent inventory' do

      let(:owner) {
        create(:user)
      }

      let(:inventory) {
        create(:inventory, :with_participants, :with_facilitators, participants: 2, facilitators: 2, owner: owner)
      }

      subject {
        create(:analysis, inventory: inventory, owner: owner)
      }

      it {
        expect(subject.owner).to equal owner
      }

      it 'does not register the owner as a particpant' do
        expect(subject.participants.map(&:user).include?(owner)).to be false
      end

      it 'does not register the owner as a facilitator' do
        expect(subject.facilitators.map(&:user).include?(owner)).to be false
      end
    end

    context 'when user creating new analysis is a facilitator of its parent inventory' do

      let(:owner) {
        inventory.facilitators.sample.user
      }

      let(:inventory) {
        create(:inventory, :with_participants, :with_facilitators, participants: 2, facilitators: 2)
      }

      subject {
        create(:analysis, inventory: inventory, owner: owner)
      }


      it {
        expect(subject.owner).to equal owner
      }

      it 'does not copy the user across as a facilitator' do
        expect(subject.facilitators.map(&:user).include?(owner)).to be false
      end

      it 'adds the owner of the original inventory as a facilitator' do
        expect(subject.facilitators.map(&:user).include?(inventory.owner)).to be true
      end
    end

    context 'when user creating new analysis is a participant of its parent inventory' do

      let(:owner) {
        inventory.participants.sample.user
      }

      let(:inventory) {
        create(:inventory, :with_participants, :with_facilitators, participants: 2, facilitators: 2)
      }

      subject {
        create(:analysis, inventory: inventory, owner: owner)
      }

      it {
        expect(subject.owner).to equal owner
      }

      it 'does not copy the user across as a participant' do
        expect(subject.participants.map(&:user).include?(owner)).to be false
      end

      it 'adds the owner of the original inventory as a facilitator' do
        expect(subject.facilitators.map(&:user).include?(inventory.owner)).to be true
      end
    end
  end
end
