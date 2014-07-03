# == Schema Information
#
# Table name: assessments
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  due_date        :datetime
#  meeting_date    :datetime
#  user_id         :integer
#  rubric_id       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  district_id     :integer
#  message         :text
#  assigned_at     :datetime
#  mandrill_id     :string(255)
#  mandrill_html   :text
#  report_takeaway :text
#

class Assessment < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer_name = 'AssessmentAuthorizer'

  default_scope { order("created_at DESC") }

	belongs_to :user
	belongs_to :rubric
	belongs_to :district
	has_one :response, as: :responder, dependent: :destroy
	has_many :participants, dependent: :destroy
	has_many :messages, dependent: :destroy
	has_many :categories, through: :questions

	has_many :users, through: :participants
	accepts_nested_attributes_for :participants, allow_destroy: true

	attr_accessor :add_participants

	## VALIDATIONS
	validates :name, presence: true
	validates :rubric_id, presence: true
	validates :district_id, presence: true
	validates :due_date, presence: true, if: "assigned_at.present?"
	validates :message, presence: true, if: "assigned_at.present?"

	validate :validate_participants, if: "assigned_at.present?"

	def validate_participants
    return unless self.participants.empty?
		errors.add :participant_ids, "You must assign participants to this assessment." 
	end
	
	## ASSESSMENT METHODS FOR RESPONSES
  def status
    return :draft if assigned_at.nil?  
    return :consensus if response.present?
    :assessment
  end

  def participant?(user)
    participants
      .where(user_id: user.id)
      .present?
  end

	def completed?
		percent_completed == 100
	end

	def assigned?
    assigned_at.present?
  end

  def has_response?
    response.present?
  end

  def response_submitted?
    response.submitted_at.present?
  end

	def percent_completed
    participant_responses.count.to_d/participants.count.to_d*100
	end

	def score_count(question_id, value)
    response_ids = participant_responses.pluck(:id)
		Score.where(value: value,
      question_id: question_id,
      response_id: response_ids).count
	end

	def modal_score(question_id)
	  descriptive_stats(scores(question_id)).mode
	end

	def variance(question_id)
    descriptive_stats(scores(question_id)).variance.tap do |v|
      return 0.0 if v.nil? || v.nan?
    end
	end

	def consensus
    Response
      .find_by(responder_id: id, responder_type: 'Assessment')
  end

  def descriptive_stats(scores)
		DescriptiveStatistics::Stats
		  .new(scores)
  end

  def all_scores
    Score
      .where(response_id: participant_responses.pluck(:id))
      .where.not(value: nil)
  end

  def response_scores
    Score
      .where(response_id: all_participant_responses.pluck(:id))
  end

	def scores(question_id)
    response_scores
      .where(question_id: question_id)
      .pluck(:value)
      .compact
  end

	def consensus_score(question_id)
    return unless response
    Score
      .find_by(question_id: question_id,
               response_id: self.response.id).value
	end

  def responses(user)
    participant = participants.find_by(user: user) 
    return [] unless participant
    [participant.response].compact
  end

	## methods for participants
  #TODO: extract
	def participant_responses
      all_participant_responses
      .where.not(submitted_at: nil)
	end

	def participants_not_responded
    participants
      .joins('LEFT JOIN responses ON responses.responder_id = participants.id')
      .where('responses.submitted_at IS NULL')
  end

	def participants_viewed_report
    participants.includes(:user)
      .where.not(report_viewed_at: nil)
	end

	def all_participant_responses
		Response.where(responder_type: 'Participant', 
		 responder: participants)
  end

	
	def consensus_responses
		self
		  .includes(:response)
		  .where("responses.responder_type = 'Assessment' AND responses.submitted_at IS NOT NULL")
		  .references(:responses)
	end

	def self.consensus_responses
		Assessment
	    .includes(:response)
	    .where("responses.responder_type = 'Assessment' AND responses.submitted_at IS NOT NULL")
	    .references(:responses)
	end

  def self.assessments_for_user(user)
    if user.role.to_sym == :member  
      assessments_for_member(user)
    else
      assessments_for_facilitator(user)
    end
  end

  def self.assessments_for_facilitator(user)
    districts = user.district_ids
    includes(participants: :user).where(district_id: districts)
  end

  def self.assessments_for_member(user)
    assessments = user.participants.select(:assessment_id)
    includes(participants: :user).where(id: assessments)
  end
end
