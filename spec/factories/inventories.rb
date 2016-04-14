# == Schema Information
#
# Table name: inventories
#
#  id          :integer          not null, primary key
#  name        :text             not null
#  deadline    :datetime         not null
#  district_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :integer
#

FactoryGirl.define do
  factory :inventory do
    name { Faker::Lorem.word }
    deadline { Faker::Date.between(1.day.from_now, 1.year.from_now) }
    association :district
    association :owner, factory: :user

    trait :with_members do
      transient do
        members 1
      end

      after(:create) do |inventory, evaluator|
        inventory.members << FactoryGirl.create_list(:inventory_member, evaluator.members)
      end
    end

    trait :with_facilitators do
      transient do
        facilitators 1
      end

      after(:create) do |inventory, evaluator|
        FactoryGirl.create_list(:inventory_member, evaluator.facilitators, :as_facilitator, inventory: inventory)
      end
    end

    trait :with_participants do
      transient do
        participants 1
      end

      after(:create) do |inventory, evaluator|
        FactoryGirl.create_list(:inventory_member, evaluator.participants, :as_participant, inventory: inventory)
      end
    end
  end
end
