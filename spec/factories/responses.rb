# == Schema Information
#
# Table name: responses
#
#  id                   :integer          not null, primary key
#  responder_id         :integer
#  responder_type       :string(255)
#  rubric_id            :integer
#  submitted_at         :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  notification_sent_at :datetime
#

FactoryGirl.define do
  factory :response do
    association :rubric

    trait :as_assessment_responder do
      responder_type 'Assessment'
      responder { create(:user) }
    end
  end
end

