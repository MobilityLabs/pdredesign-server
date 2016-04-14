# == Schema Information
#
# Table name: data_entry_questions
#
#  id                   :integer          not null, primary key
#  who_enters_data      :text
#  how_data_is_entered  :text
#  when_data_is_entered :text
#  created_at           :datetime
#  updated_at           :datetime
#  data_entry_id        :integer
#

require 'spec_helper'

describe DataEntryQuestion do

  it { is_expected.to belong_to(:data_entry) }

  it { is_expected.not_to allow_value('foo').for(:when_data_is_entered) }

  DataEntryQuestion.data_entered_frequencies.values.each { |frequency|
    it { is_expected.to allow_value(frequency).for(:when_data_is_entered) }
  }

end
