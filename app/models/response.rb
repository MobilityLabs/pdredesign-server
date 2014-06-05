# == Schema Information
#
# Table name: responses
#
#  id                   :integer          not null, primary key
#  responder_id         :integer
#  responder_type       :string(255)
#  rubric_id            :integer
#  submitted_at         :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  notification_sent_at :datetime
#

class Response < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer_name = 'ResponseAuthorizer'

	belongs_to :responder, polymorphic: true
	belongs_to :rubric

	has_many :questions, through: :rubric
  has_many :categories, -> { uniq.order('id ASC') }, through: :questions

	has_many :scores, dependent: :destroy
	has_many :feedbacks, dependent: :destroy

	accepts_nested_attributes_for :scores
	accepts_nested_attributes_for :feedbacks
  

  before_save do |response| 
    if response.responder_type == 'Assessment'
      response.responder.update_column(:meeting_date, Time.now) 
    end
  end

  def is_consensus?
    responder_type == 'Assessment'
  end

	def completed?
    submitted_at.present?
	end

	def percent_completed
		return (entered_scores_count/questions_count)*100
	end

  private
  def questions_count
    questions
      .count
      .to_d
  end

  def entered_scores_count 
    scores
      .where("value IS NOT NULL AND evidence IS NOT NULL")
      .count
      .to_d
  end

end
