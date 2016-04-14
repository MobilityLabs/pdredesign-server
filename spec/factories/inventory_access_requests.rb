# == Schema Information
#
# Table name: inventory_access_requests
#
#  id           :integer          not null, primary key
#  inventory_id :integer          not null
#  user_id      :integer          not null
#  role         :string           not null
#  token        :string
#  created_at   :datetime
#  updated_at   :datetime
#

FactoryGirl.define do
  factory :inventory_access_request do
    association :inventory
    association :user

    trait :as_facilitator do
      role 'facilitator'
    end

    trait :as_participant do
      role 'participant'
    end
  end
end
