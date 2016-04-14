# == Schema Information
#
# Table name: inventory_invitations
#
#  id           :integer          not null, primary key
#  first_name   :string
#  last_name    :string
#  email        :string
#  team_role    :string
#  role         :string
#  token        :string
#  inventory_id :integer          not null
#  user_id      :integer
#

class InventoryInvitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :inventory

  validates :email, presence: true
  validates :inventory_id, presence: true
  validates :email, uniqueness: { scope: :inventory_id, message: 'User has already been invited' }

  before_create :create_token

  def email=(value)
    self[:email] = (value && value.downcase)
  end

  private
  def create_token
    self.token ||= generate_hash 
  end

  def generate_hash
    SecureRandom.hex[0..9]
  end
end
