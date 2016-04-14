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

FactoryGirl.define do
  factory :data_entry_question do
    when_data_is_entered DataEntryQuestion.data_entered_frequencies[:yearly]
  end
end
