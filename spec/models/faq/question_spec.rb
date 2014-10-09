require 'spec_helper'

describe Faq::Question do
  let(:subject) { Faq::Question }
  it 'requires :content, :answer, :tool_id' do
    question = subject.new()
    question.valid?

    expect(question.errors[:content]).not_to be_empty
    expect(question.errors[:answer]).not_to  be_empty
    expect(question.errors[:tool_id]).not_to be_empty
  end

  it 'creates a valid record' do
    question = subject.new(
                 content: 'some content',
                 answer:  'some answer',
                 tool_id: 1)
    expect(question.valid?).to eq(true)
  end

  it 'has the tool relationship' do
    tool     = Tool.create!(
                 title:' some question')

    question = subject.new(
                 content: 'some content',
                 answer:  'some answer',
                 tool: tool)
    expect(question.valid?).to eq(true)
    expect(question.tool_id).to eq(tool.id)

  end

end

