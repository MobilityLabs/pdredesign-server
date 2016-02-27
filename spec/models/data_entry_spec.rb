# == Schema Information
#
# Table name: data_entries
#
#  id                       :integer          not null, primary key
#  general_data_question_id :integer          not null
#  data_entry_question_id   :integer          not null
#  data_access_question_id  :integer          not null
#  created_at               :datetime
#  updated_at               :datetime
#

require 'spec_helper'

describe DataEntry do
  it { is_expected.to have_one(:general_data_question) }
  it { is_expected.to have_one(:data_entry_question) }
  it { is_expected.to have_one(:data_access_question) }

  it { is_expected.to belong_to(:inventory) }

  it { is_expected.to validate_presence_of(:general_data_question) }

  it { is_expected.to accept_nested_attributes_for(:general_data_question)}
  it { is_expected.to accept_nested_attributes_for(:data_entry_question)}
  it { is_expected.to accept_nested_attributes_for(:data_access_question)}
end
