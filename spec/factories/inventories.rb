# == Schema Information
#
# Table name: inventories
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  deadline    :datetime         not null
#  district_id :integer          not null
#

FactoryGirl.define do
  factory :inventory do
    name { Faker::Lorem.word }
    deadline { Faker::Date.between(2.days.ago, Date.today) }
    association :district
  end
end
