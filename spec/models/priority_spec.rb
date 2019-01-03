# == Schema Information
#
# Table name: priorities
#
#  id         :integer          not null, primary key
#  tool_id    :integer
#  order      :integer          is an Array
#  created_at :datetime
#  updated_at :datetime
#  tool_type  :string
#

require 'spec_helper'

describe Priority do
  it { is_expected.to belong_to(:tool) }
  it { is_expected.to validate_presence_of(:tool) }
  it { is_expected.to validate_presence_of(:order) }

  context 'when inserting an Analysis and an Assessment with the same tool ID' do
    let(:assessment) {
      create(:assessment, id: 99001)
    }

    let(:analysis) {
      create(:analysis, id: 99001)
    }

    let(:first_priority) {
      Priority.create(tool: assessment, order: [1, 2, 3])
    }

    let(:second_priority) {
      Priority.create(tool: analysis, order: [1, 2, 3])
    }

    before(:each) do
      first_priority.save!
      second_priority.save
    end

    it 'is a valid second save' do
      expect(second_priority.valid?).to be true
    end
  end

  context 'when inserting two Assessments with the same tool ID' do
    let(:assessment1) {
      create(:assessment, id: 99001)
    }

    let(:first_priority) {
      Priority.create(tool: assessment1, order: [1, 2, 3])
    }

    let(:second_priority) {
      Priority.create(tool: assessment1, order: [1, 2, 3])
    }

    before(:each) do
      first_priority.save!
      second_priority.save
    end

    it 'is invalid' do
      expect(second_priority.invalid?).to be true
    end

    it 'errors specifically with the tool_id being taken' do
      expect(second_priority.errors[:tool_id]).to eq ['has already been taken']
    end
  end
end
