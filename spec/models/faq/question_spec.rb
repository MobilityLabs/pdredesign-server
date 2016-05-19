# == Schema Information
#
# Table name: faq_questions
#
#  id          :integer          not null, primary key
#  role        :string
#  topic       :string
#  category_id :integer
#  content     :text
#  answer      :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Faq::Question do
  let(:subject) { Faq::Question }
  it 'requires :content, :answer, :tool_id' do
    question = subject.new()
    question.valid?

    expect(question.errors[:content]).not_to be_empty
    expect(question.errors[:answer]).not_to  be_empty
    expect(question.errors[:category_id]).not_to be_empty
  end

  it 'creates a valid record' do
    category = Faq::Category.create(heading: 'example')
    question = subject.new(
                 category: category,
                 content: 'some content',
                 answer:  'some answer')
    expect(question.valid?).to eq(true)
  end
  
end

