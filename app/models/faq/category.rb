# == Schema Information
#
# Table name: faq_categories
#
#  id         :integer          not null, primary key
#  heading    :string
#  created_at :datetime
#  updated_at :datetime
#

class Faq::Category < ActiveRecord::Base
  has_many :questions, class_name: 'Faq::Question'
  validates :heading, presence: true
end
