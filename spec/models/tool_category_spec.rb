# == Schema Information
#
# Table name: tool_categories
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  display_order :integer
#  tool_phase_id :integer
#

require 'spec_helper'

describe ToolCategory do
  it '#tools returns all tools for this category' do
    phase    = ToolPhase.create(title: 'test', description: 'description') 
    category = ToolCategory.create(title: 'category', tool_phase: phase)

    5.times {
      Tool.create!(tool_category_id: category.id, title: 'Some title', description:'', url:'')
    }

    expect(category.tools.count).to eq(5)
  end
end
