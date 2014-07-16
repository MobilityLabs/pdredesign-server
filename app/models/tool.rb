# == Schema Information
#
# Table name: tools
#
#  id                  :integer          not null, primary key
#  title               :string(255)
#  description         :text
#  url                 :string(255)
#  is_default          :boolean
#  display_order       :integer
#  tool_category_id    :integer
#  tool_subcategory_id :integer
#  user_id             :integer
#

class Tool < ActiveRecord::Base
  belongs_to :tool_category
  belongs_to :tool_subcategory
  belongs_to :user

  scope :the_defaults, -> { where(is_default: true) }
end
