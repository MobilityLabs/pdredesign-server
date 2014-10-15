class UserInvitationNotificationWorker
  include ::Sidekiq::Worker

  def perform(invite_id)
    invite = find_invite(invite_id)
    NotificationsMailer.invite(invite).deliver

    participant = find_participant(invite)
    participant.update(invited_at: Time.now)
  end

  private
  def find_participant(invite)
    Participant.find_by(user_id: invite.user_id, assessment_id: invite.assessment_id)
  end

  def find_invite(invite_id)
    UserInvitation.find(invite_id)
  end

end
