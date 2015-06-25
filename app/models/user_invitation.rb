# == Schema Information
#
# Table name: user_invitations
#
#  id            :integer          not null, primary key
#  first_name    :string(255)
#  last_name     :string(255)
#  email         :string(255)
#  team_role     :string(255)
#  token         :string(255)
#  assessment_id :integer
#  user_id       :integer
#

class UserInvitation < ActiveRecord::Base
  validates :email, presence: true
  validates :assessment_id, presence: true
  validates :email, uniqueness: { scope: :assessment_id, message: 'User has already been invited' }

  before_create :create_token

  belongs_to :assessment
  belongs_to :user

  attr_accessor :role

  def email=(value)
    self[:email] = (value && value.downcase)
  end

  private

  def create_token
    return if token
    self.token = generate_hash 
  end

  def generate_hash
    SecureRandom.hex[0..9]
  end
end
