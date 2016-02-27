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
#

class UsageQuestion < ActiveRecord::Base

end
