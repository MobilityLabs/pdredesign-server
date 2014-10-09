class Faq::Category < ActiveRecord::Base
  has_many  :faq_questions
  validates :heading, presence: true
end
