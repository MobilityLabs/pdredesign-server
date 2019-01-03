# == Schema Information
#
# Table name: faq_questions
#
#  id          :integer          not null, primary key
#  role        :string(255)
#  topic       :string(255)
#  category_id :integer
#  content     :text
#  answer      :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Faq::Question < ActiveRecord::Base
  belongs_to :category, class_name: 'Faq::Category'

  validates :content, presence: true
  validates :answer,  presence: true
  validates :category_id,  presence: true
end
