# == Schema Information
#
# Table name: data_entry_questions
#
#  id                   :integer          not null, primary key
#  who_enters_data      :string
#  how_data_is_entered  :string
#  when_data_is_entered :string
#  created_at           :datetime
#  updated_at           :datetime
#  data_entry_id        :integer
#

FactoryGirl.define do
  factory :data_entry_question do
    when_data_is_entered DataEntryQuestion.data_entered_frequencies[:yearly]
  end
end
