# == Schema Information
#
# Table name: analyses
#
#  id              :integer          not null, primary key
#  name            :text
#  deadline        :datetime
#  inventory_id    :integer
#  created_at      :datetime
#  updated_at      :datetime
#  message         :text
#  assigned_at     :datetime
#  rubric_id       :integer
#  owner_id        :integer
#  report_takeaway :text
#  share_token     :string
#

class Analysis < ActiveRecord::Base
  include Authority::Abilities
  include MessageMigrationConcern
  include MembershipConcern
  include ToolOwnerMembershipConcern

  belongs_to :inventory
  belongs_to :rubric
  belongs_to :owner, class_name: 'User'

  has_one :response, as: :responder, dependent: :destroy
  has_many :messages, as: :tool
  has_many :tool_members, as: :tool
  has_many :access_requests, as: :tool
  has_many :participants, -> {
    where(tool_type: 'Analysis').
      where('? = ANY(roles)', ToolMember.member_roles[:participant])
  }, foreign_key: :tool_id, class_name: 'ToolMember'

  has_many :facilitators, -> {
    where(tool_type: 'Analysis').
      where('? = ANY(roles)', ToolMember.member_roles[:facilitator])
  }, foreign_key: :tool_id, class_name: 'ToolMember'

  attr_accessor :assign

  #Exposed alias for testing
  alias_attribute :due_date, :deadline
  alias_attribute :user, :owner

  delegate :district, to: :inventory, prefix: false
  delegate :district_id, to: :inventory, prefix: false

  validates_presence_of :name, :deadline, :inventory, :rubric, :owner
  validates :message, presence: true, if: -> { assigned_at.present? }

  after_create :set_members_from_inventory

  before_save :set_assigned_at,
              :ensure_share_token

  after_save :synchronize_members_with_parent

  def team_roles_for_participants
    self.tool_members
        .includes(:user)
        .pluck('users.team_role')
        .uniq
        .compact
  end

  def status
    return :draft if self.assigned_at.nil?
    :consensus
  end

  def fully_complete?
    response && response.completed?
  end

  def consensus
    @consensus ||= Response.where(responder_id: self.id, responder_type: 'Analysis').first
  end

  def pending_requests?(user)
    return false if user.nil?
    access_requests.exists?(user: user)
  end

  private
  def set_members_from_inventory
    %i|participants facilitators|.each do |member_type|
      self.inventory.send(member_type).each do |tool_member|
        unless self.owner == tool_member.user
          self.send(member_type).create(user: tool_member.user,
                                        roles: [MembershipHelper.dehumanize_role(member_type.to_s.singularize)])
        end
      end
    end
  end

  def set_assigned_at
    self.assigned_at = Time.now if self.assign
  end

  def ensure_share_token
    self.share_token ||= SecureRandom.hex(32)
  end

  def synchronize_members_with_parent
    inventory_member_ids = self.inventory.tool_members.pluck(:user_id)
    analysis_member_ids = self.tool_members.pluck(:user_id)
    members_missing_from_inventory = (inventory_member_ids | analysis_member_ids) - inventory_member_ids

    members_missing_from_inventory.each { |user_id|
      begin
        self.inventory.tool_members.create(user_id: user_id, roles: [ToolMember.member_roles[:participant]])
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    }
  end
end
