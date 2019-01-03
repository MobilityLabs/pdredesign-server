# == Schema Information
#
# Table name: inventories
#
#  id          :integer          not null, primary key
#  name        :text             not null
#  deadline    :datetime         not null
#  district_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :integer
#  message     :text
#  assigned_at :datetime
#  share_token :string
#

class Inventory < ActiveRecord::Base
  include Authority::Abilities
  include MessageMigrationConcern
  include MembershipConcern
  include ToolOwnerMembershipConcern

  default_scope { order(created_at: :desc) }

  belongs_to :district
  belongs_to :owner, class_name: 'User'

  has_many :product_entries
  has_many :data_entries
  has_many :access_requests, as: :tool
  has_many :messages, as: :tool
  has_many :analyses
  has_many :tool_members, as: :tool

  has_many :participants, -> {
    where(tool_type: 'Inventory').
      where('? = ANY(roles)', ToolMember.member_roles[:participant])
  }, foreign_key: :tool_id, class_name: 'ToolMember'

  has_many :facilitators, -> {
    where(tool_type: 'Inventory').
      where('? = ANY(roles)', ToolMember.member_roles[:facilitator])
  }, foreign_key: :tool_id, class_name: 'ToolMember'

  validates_length_of :name, minimum: 1, maximum: 255
  validates_presence_of :owner
  validates_presence_of :deadline
  validates_presence_of :message, if: -> { assigned_at.present? }
  validates :deadline, date: true

  accepts_nested_attributes_for :product_entries
  accepts_nested_attributes_for :data_entries

  attr_accessor :assign
  # Exposed alias for testing
  alias_attribute :user, :owner
  alias_attribute :due_date, :deadline

  before_save :ensure_share_token,
              :set_assigned_at

  def owner?(user)
    self.owner_id == user.id
  end

  def status
    return :draft if self.assigned_at.nil?
    :inventory
  end

  def participant_count
    participants.count
  end

  def current_analysis
    analyses.last
  end

  def pending_requests?(user)
    access_requests.where(user: user).present?
  end

  private
  def set_assigned_at
    self.assigned_at = Time.now if self.assign
  end

  def ensure_share_token
    self.share_token ||= SecureRandom.hex(32)
  end
end
