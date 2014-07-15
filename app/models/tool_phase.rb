# == Schema Information
#
# Table name: tool_phases
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  description   :text
#  display_order :integer
#

class ToolPhase < ActiveRecord::Base
end
