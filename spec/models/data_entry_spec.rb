# == Schema Information
#
# Table name: data_entries
#
#  id           :integer          not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  inventory_id :integer
#  name         :text
#  deleted_at   :datetime
#

require 'spec_helper'

describe DataEntry do
  it { is_expected.to have_one(:general_data_question) }
  it { is_expected.to have_one(:data_entry_question) }
  it { is_expected.to have_one(:data_access_question) }

  it { is_expected.to belong_to(:inventory) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:general_data_question) }

  it { is_expected.to accept_nested_attributes_for(:general_data_question) }
  it { is_expected.to accept_nested_attributes_for(:data_entry_question) }
  it { is_expected.to accept_nested_attributes_for(:data_access_question) }

  describe '#save' do
    subject { FactoryGirl.create(:data_entry) }

    it { expect(subject.new_record?).to be false }
  end
end
