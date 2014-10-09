# == Schema Information
#
# Table name: faq_categories
#
#  id         :integer          not null, primary key
#  heading    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Faq::Category < ActiveRecord::Base
  has_many  :faq_questions
  validates :heading, presence: true
end
