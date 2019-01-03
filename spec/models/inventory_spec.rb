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
#  message     :text
#  assigned_at :datetime
#  share_token :string
#

require 'spec_helper'
require 'support/message_migration_concern_shared_example'

describe Inventory do
  it_behaves_like 'a tool which adds initial messages', described_class.to_s.downcase
  it { is_expected.to have_many(:product_entries) }
  it { is_expected.to have_many(:data_entries) }
  it { is_expected.to have_many(:access_requests) }
  it { is_expected.to have_many(:facilitators) }
  it { is_expected.to have_many(:participants) }
  it { is_expected.to have_many(:messages) }

  it { is_expected.to belong_to(:district) }
  it { is_expected.to belong_to(:owner) }

  it { is_expected.to accept_nested_attributes_for(:product_entries) }
  it { is_expected.to accept_nested_attributes_for(:data_entries) }

  it { is_expected.to validate_length_of(:name).is_at_least(1) }
  it { is_expected.to validate_length_of(:name).is_at_most(255) }
  it { is_expected.to validate_presence_of(:deadline) }

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
    let(:owner) { create(:user) }
    subject { create(:inventory, owner: owner) }

    it { expect(subject.new_record?).to be false }
    it 'add owner as facilitator' do
      expect(subject.facilitators.where(user: owner)).to exist
    end
  end

  describe '#share_token' do
    let(:inventory) { create(:inventory) }
    let!(:original_share_token) { inventory.share_token }
    it do
      expect(inventory.share_token).not_to be_empty
    end

    describe 'when saved again' do 
      before do
        inventory.save!
      end
      it do
        expect(inventory.share_token).to eq original_share_token
      end
    end
  end

  describe '#owner?' do
    context 'owner is current user' do
      let(:inventory) { create(:inventory) }

      it do
        expect(inventory.owner?(inventory.owner)).to be true
      end
    end

    context 'owner is a different user' do
      let(:inventory) { create(:inventory) }
      let(:user) { create(:user) }

      it do
        expect(inventory.owner?(user)).to be false
      end
    end
  end

  describe '#member?' do
    context 'user is member' do
      let(:inventory) { create(:inventory, :with_members) }
      let(:user) { inventory.tool_members.first.user }

      it do
        expect(inventory.member?(user)).to be true
      end
    end

    context 'user is not member' do
      let(:inventory) { create(:inventory, :with_members) }
      let(:user) { create(:user) }

      it do
        expect(inventory.member?(user)).to be false
      end
    end
  end

  describe '#current_analysis' do
    let(:inventory) { create(:inventory) }
    let!(:last_analysis) { create_list(:analysis, 6, inventory: inventory).last }

    it { expect(inventory.current_analysis).to eq last_analysis }
  end
end
