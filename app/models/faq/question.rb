# == Schema Information
#
# Table name: faq_questions
#
#  id         :integer          not null, primary key
#  tool_id    :integer
#  role       :string(255)
#  category   :string(255)
#  content    :string(255)
#  answer     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Faq::Question < ActiveRecord::Base
  belongs_to :category, class: Faq::Category

  validates :content, presence: true
  validates :answer,  presence: true
  validates :category_id,  presence: true
end
