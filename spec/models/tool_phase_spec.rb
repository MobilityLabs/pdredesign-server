# == Schema Information
#
# Table name: tool_phases
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  description   :text
#  display_order :integer
#

require 'spec_helper'

describe ToolPhase do
  it 'has the default ordering' do
    ToolPhase.create!(title: 'third', description: 'tmp', display_order: 3)  
    ToolPhase.create!(title: 'first', description: 'tmp', display_order: 1)  
    ToolPhase.create!(title: 'second', description: 'tmp', display_order: 2)  

    phases = ToolPhase.all
    expect(phases[0][:title]).to eq('first')
    expect(phases[1][:title]).to eq('second')
    expect(phases[2][:title]).to eq('third')
  end
end
