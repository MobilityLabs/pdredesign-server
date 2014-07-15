# == Schema Information
#
# Table name: tool_categories
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  display_order :integer
#  tool_phase_id :integer
#

class ToolCategory < ActiveRecord::Base
  belongs_to :tool_phase
end
