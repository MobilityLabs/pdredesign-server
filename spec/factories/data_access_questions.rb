# == Schema Information
#
# Table name: data_access_questions
#
#  id                   :integer          not null, primary key
#  data_storage         :text
#  who_access_data      :text
#  how_data_is_accessed :text
#  why_data_is_accessed :text
#  notes                :text
#  created_at           :datetime
#  updated_at           :datetime
#  data_entry_id        :integer
#

FactoryGirl.define do
  factory :data_access_question
end
