class UserInvitation < ActiveRecord::Base
  validates :email, presence: true
  validates :assessment_id, presence: true

  before_create :create_token

  private
  def create_token
    self.token = hash
  end

  def hash
    SecureRandom.hex[0..9]
  end
end
