class Faq::Question < ActiveRecord::Base
  belongs_to :tool

  validates :content, presence: true
  validates :answer,  presence: true
  validates :tool_id, presence: true
end
