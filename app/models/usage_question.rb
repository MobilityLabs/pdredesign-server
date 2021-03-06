# == Schema Information
#
# Table name: usage_questions
#
#  id               :integer          not null, primary key
#  school_usage     :text
#  usage            :text
#  vendor_data      :text
#  notes            :text
#  created_at       :datetime
#  updated_at       :datetime
#  product_entry_id :integer
#  deleted_at       :datetime
#

class UsageQuestion < ActiveRecord::Base
  belongs_to :product_entry

  acts_as_paranoid
end
