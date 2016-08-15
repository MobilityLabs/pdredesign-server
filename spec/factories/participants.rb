# == Schema Information
#
# Table name: participants
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  assessment_id    :integer
#  created_at       :datetime
#  updated_at       :datetime
#  invited_at       :datetime
#  reminded_at      :datetime
#  report_viewed_at :datetime
#

FactoryGirl.define do
  factory :participant do
    association :user
    trait :with_users do
      after(:create) do |participant|
        participant.user = FactoryGirl.create(:user, :with_district)
      end
    end

    trait :with_assessment do
      association :assessment
    end
  end
end
