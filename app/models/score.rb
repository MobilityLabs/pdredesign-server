# == Schema Information
#
# Table name: scores
#
#  id          :integer          not null, primary key
#  value       :integer
#  evidence    :text
#  response_id :integer
#  question_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Score < ActiveRecord::Base
	belongs_to :response
	belongs_to :question

  has_one :participant,
    through: :response,
    source:  :responder,
    source_type: Participant

  has_one :user, through: :participant
end
