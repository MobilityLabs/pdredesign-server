# == Schema Information
#
# Table name: data_access_questions
#
#  id                   :integer          not null, primary key
#  data_storage         :string
#  who_access_data      :string
#  how_data_is_accessed :string
#  why_data_is_accessed :string
#  notes                :string
#  created_at           :datetime
#  updated_at           :datetime
#  data_entry_id        :integer
#

FactoryGirl.define do
  factory :data_access_question
end
