class Faq::Question < ActiveRecord::Base
  validates :content, presence: true
  validates :answer,  presence: true
  validates :tool_id, presence: true
end
