# == Schema Information
#
# Table name: questions
#
#  id          :integer          not null, primary key
#  headline    :string(255)
#  content     :text
#  order       :integer
#  category_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  help_text   :text
#

FactoryGirl.define do
  factory :question
end
