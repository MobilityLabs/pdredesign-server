# == Schema Information
#
# Table name: technical_questions
#
#  id               :integer          not null, primary key
#  platform         :text             default([]), is an Array
#  hosting          :text
#  connectivity     :text
#  single_sign_on   :text
#  created_at       :datetime
#  updated_at       :datetime
#  product_entry_id :integer
#

FactoryGirl.define do
  factory :technical_question
end
