# == Schema Information
#
# Table name: user_invitations
#
#  id            :integer          not null, primary key
#  first_name    :string
#  last_name     :string
#  email         :string
#  team_role     :string
#  token         :string
#  assessment_id :integer
#  user_id       :integer
#

FactoryGirl.define do
  factory :user_invitation do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    team_role { Faker::Commerce.department }
    email { Faker::Internet.email }

    trait :as_facilitator do
      role 'facilitator'
    end

    trait :as_participant do
      role 'participant'
    end
  end
end
