# == Schema Information
#
# Table name: assessments
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  due_date        :datetime
#  meeting_date    :datetime
#  user_id         :integer
#  rubric_id       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  district_id     :integer
#  message         :text
#  assigned_at     :datetime
#  mandrill_id     :string(255)
#  mandrill_html   :text
#  report_takeaway :text
#

FactoryGirl.define do
  factory :assessment do
    name { Faker::Lorem.word }
    association :rubric
    association :district

    trait :with_response do
      association :response, :as_assessment_responder
    end

  end
end
