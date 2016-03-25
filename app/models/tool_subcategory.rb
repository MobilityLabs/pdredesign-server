# == Schema Information
#
# Table name: tool_subcategories
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  display_order    :integer
#  tool_category_id :integer
#

class ToolSubcategory < ActiveRecord::Base
  belongs_to :tool_category
  has_many   :tools
end
