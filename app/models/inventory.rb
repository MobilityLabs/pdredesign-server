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
#

class Inventory < ActiveRecord::Base
  include Authority::Abilities
  has_many :product_entries
  has_many :data_entries
  has_many :access_requests, class_name: 'InventoryAccessRequest'
  belongs_to :district
  belongs_to :owner, class_name: 'User'
  self.authorizer_name = 'InventoryAuthorizer'

  validates_length_of :name, minimum: 1, maximum: 255
  validates_presence_of :owner
  validates_presence_of :deadline

  validates :deadline, date: true

  accepts_nested_attributes_for :product_entries
  accepts_nested_attributes_for :data_entries

  has_many :members, class_name:'InventoryMember'
  has_many :participants, -> { where(role: 'participant') }, class_name:'InventoryMember'
  has_many :facilitators, -> { where(role: 'facilitator') }, class_name:'InventoryMember'

  after_create :add_facilitator_owner

  def facilitator?(user:)
    facilitators.where(user: user).exists?
  end

  def participant?(user:)
    participants.where(user: user).exists?
  end

  def owner?(user:)
    self.owner_id == user.id
  end

  def member?(user:)
    self.members.where(user: user).exists?
  end

  private
  def add_facilitator_owner
    return unless owner
    facilitators.create(user: owner)
  end
end
