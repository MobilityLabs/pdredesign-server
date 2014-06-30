class UserInvitation < ActiveRecord::Base
  validates :email, presence: true
  validates :assessment_id, presence: true

end
