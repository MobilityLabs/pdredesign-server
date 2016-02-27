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
#  price                       :decimal(9, 2)
#  data_type                   :text             default([]), is an Array
#  purpose                     :text
#  created_at                  :datetime
#  updated_at                  :datetime
#  product_entry_id            :integer
#

require 'spec_helper'

describe GeneralInventoryQuestion do

  it { is_expected.to_not allow_value(['foo']).for(:data_type) }
  it { is_expected.to allow_value(GeneralInventoryQuestion.product_types.values).for(:data_type) }
end
