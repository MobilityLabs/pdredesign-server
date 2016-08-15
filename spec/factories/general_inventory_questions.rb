# == Schema Information
#
# Table name: general_inventory_questions
#
#  id                          :integer          not null, primary key
#  product_name                :text
#  vendor                      :text
#  point_of_contact_name       :text
#  point_of_contact_department :text
#  pricing_structure           :text
#  price_in_cents              :integer
#  data_type                   :text             default([]), is an Array
#  purpose                     :text
#  created_at                  :datetime
#  updated_at                  :datetime
#  product_entry_id            :integer
#  deleted_at                  :datetime
#

FactoryGirl.define do
  factory :general_inventory_question do
    product_name { Faker::Lorem.word }
  end
end
