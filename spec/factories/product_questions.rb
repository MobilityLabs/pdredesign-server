# == Schema Information
#
# Table name: product_questions
#
#  id               :integer          not null, primary key
#  how_its_assigned :text             default([]), is an Array
#  how_its_used     :text             default([]), is an Array
#  how_its_accessed :text             default([]), is an Array
#  audience         :text             default([]), is an Array
#  created_at       :datetime
#  updated_at       :datetime
#  product_entry_id :integer
#

FactoryGirl.define do
  factory :product_question do
    how_its_assigned ProductQuestion.assignment_approaches[:teacher_choice]
    how_its_used ProductQuestion.usage_frequencies[:blended]
    how_its_accessed ProductQuestion.accesses[:video_share]
    audience ProductQuestion.audience_types[:admin_audience]
  end
end
