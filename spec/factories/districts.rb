# == Schema Information
#
# Table name: districts
#
#  id            :integer          not null, primary key
#  lea_id        :string(255)
#  lea_type      :string(255)
#  fipst         :string(255)
#  stid          :string(255)
#  name          :string(255)
#  county_name   :string(255)
#  county_number :string(255)
#  street        :string(255)
#  city          :string(255)
#  state         :string(255)
#  zip           :string(255)
#  zip4          :string(255)
#  phone         :string(255)
#  mail_street   :string(255)
#  mail_city     :string(255)
#  mail_state    :string(255)
#  mail_zip      :string(255)
#  mail_zip4     :string(255)
#  longitude     :string(255)
#  latitude      :string(255)
#  lowest_grade  :string(255)
#  highest_grade :string(255)
#  union         :string(255)
#  csa           :string(255)
#  cbsa          :string(255)
#  metmic        :string(255)
#  ulocal        :string(255)
#  cdcode        :string(255)
#  bound         :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :district do
    name { Faker::Lorem.word }
  end
end
