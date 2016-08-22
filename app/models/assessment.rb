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
#  share_token     :string
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
  has_many :messages, as: :tool, dependent: :destroy
  has_many :questions, through: :rubric
  has_many :categories, through: :questions
  has_many :access_requests

  has_many :users, through: :participants

  has_and_belongs_to_many :facilitators,
                          class_name: 'User',
                          join_table: :assessments_facilitators

  has_and_belongs_to_many :viewers,
                          class_name: 'User',
                          join_table: :assessments_viewers

  has_and_belongs_to_many :network_partners,
                          class_name: 'User',
                          join_table: :assessments_network_partners


  accepts_nested_attributes_for :participants, allow_destroy: true

  attr_accessor :add_participants, :assign

  ## VALIDATIONS
  validates :name, presence: true
  validates :rubric_id, presence: true
  validates :district_id, presence: true
  validates :due_date, presence: true, if: 'assigned_at.present?'
  validates :message, presence: true, if: 'assigned_at.present?'

  validate :validate_participants, if: 'assigned_at.present?'
  validate :meeting_date_not_in_the_past, if: 'meeting_date.present?'

  before_save :set_assigned_at
  before_save :ensure_share_token

  def validate_participants
    return unless self.participants.empty?
    errors.add :participant_ids, 'You must assign participants to this assessment.'
  end

  def meeting_date_not_in_the_past
    eligible_date = Time.current + 1.day + 12.hours
    if self.meeting_date < eligible_date
      errors.add(:meeting_date, "must be set no earlier than #{(eligible_date).strftime('%D')}")
    end
  end

  ## ASSESSMENT METHODS FOR RESPONSES
  def status
    return :draft if assigned_at.nil?
    return :consensus if response.present?
    :assessment
  end

  def all_users
    users = []

    [:facilitators, :viewers, :network_partners].each { |user_type| users.push(send(user_type)) }

    #inlcude participants
    participants.map { |participant| users.push(participant.user) unless users.include?(participant.user) }

    users.flatten.compact.uniq.delete_if { |u| owner?(u) }
  end

  def owner?(comp_user)
    user.id == comp_user.id
  end

  def facilitator?(user)
    return true if owner?(user)
    facilitators
        .where(id: [user.id])
        .present?
  end

  def network_partner?(user)
    network_partners
        .where(id: [user.id])
        .present?
  end

  def viewer?(user)
    viewers
        .where(id: [user.id])
        .present?
  end

  def participant?(user)
    participants
        .where(user_id: user.id)
        .present?
  end

  def has_access?(user)
    facilitator?(user) || participant?(user)
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

  def fully_complete?
    has_response? && response.completed?
  end

  def pending_requests?(user)
    access_requests.where(user_id: user.id).present?
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

  def answered_scores
    response_scores
        .where.not(evidence: nil)
        .where.not(evidence: '')
  end

  def scores_for_team_role(role)
    answered_scores
        .includes(:response, :participant, :user)
        .where(users: {team_role: role})
  end

  def team_roles_for_participants
    participants
        .joins(:user)
        .pluck("users.team_role")
        .uniq
        .compact
  end

  def response_scores
    scores_for_response_ids(all_participant_responses.pluck(:id))
  end

  def scores_for_response_ids(response_ids)
    Score
        .where(response_id: response_ids)
  end

  def scores(question_id)
    response_scores
        .where(question_id: question_id)
        .pluck(:value)
        .compact
  end

  def consensus_score(question_id)
    return unless response
    Score.find_by(question_id: question_id,
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
    # Code smell; should likely be inner or even right join instead of left join to prevent pulling in
    # participants without responses
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

  def flush_cached_version
    # Caching is based at :updated_at attribute so when it changes will discard the cached version and do the caching agin.
    self.touch if persisted?
  end

  def set_assigned_at
    self.assigned_at = Time.now if self.assign
  end

  def self.consensus_responses
    Assessment
        .includes(:response)
        .where("responses.responder_type = 'Assessment' " +
                   "AND responses.submitted_at IS NOT NULL")
        .references(:responses)
  end

  def self.assessments_for_user(user)
    districts = user.district_ids
    # Code smell; we're only looking at participants when we should probably look at members
    includes(participants: :user).where(district_id: districts)
  end

  def ensure_share_token
    self.share_token ||= SecureRandom.hex(32)
  end
end
