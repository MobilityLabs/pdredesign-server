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
end

