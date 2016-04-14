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
#  share_token     :string
#

FactoryGirl.define do
  factory :assessment do
    name { Faker::Lorem.word }
    association :rubric
    association :district

    trait :with_response do
      association :response, :as_assessment_responder
    end

    trait :with_participants do
      name 'Assessment other'
      due_date Time.now
      message 'some message'
      association :rubric
      association :district
      association :user, factory: [:user, :with_district], districts: 1

      before(:create) do |assessment|
        assessment.participants = FactoryGirl.create_list(:participant, 2, :with_users)
        assessment.facilitators = [FactoryGirl.create(:user, :with_district)]
      end
    end

    trait :with_consensus do
      after(:create) do |assessment|
        assessment.update_attributes(response: FactoryGirl.create(:response, responder: assessment))
      end
    end
  end
end
