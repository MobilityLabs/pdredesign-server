# == Schema Information
#
# Table name: general_data_questions
#
#  id                          :integer          not null, primary key
#  subcategory                 :text
#  point_of_contact_name       :text
#  point_of_contact_department :text
#  data_capture                :text
#  created_at                  :datetime
#  updated_at                  :datetime
#  data_entry_id               :integer
#

FactoryGirl.define do
  factory :general_data_question
end
