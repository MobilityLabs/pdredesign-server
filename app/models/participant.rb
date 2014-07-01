# == Schema Information
#
# Table name: participants
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  assessment_id    :integer
#  created_at       :datetime
#  updated_at       :datetime
#  invited_at       :datetime
#  reminded_at      :datetime
#  report_viewed_at :datetime
#

class Participant < ActiveRecord::Base
  before_destroy :remove_invitation

	belongs_to :user
	belongs_to :assessment
  has_one :response, as: :responder, dependent: :destroy

  def remove_invitation
    UserInvitation
      .where(email: user.email, assessment: assessment)
      .destroy_all
  end

end
