class UserInvitation < ActiveRecord::Base
  validates :email, presence: true
  validates :assessment_id, presence: true
  validates :email, uniqueness: { scope: :assessment_id, message: 'User has already been invited' }

  before_create :create_token

  belongs_to :assessment
  belongs_to :user

  private
  def create_token
    self.token = hash
  end

  def hash
    SecureRandom.hex[0..9]
  end
end
