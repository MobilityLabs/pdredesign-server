class UserInvitationNotificationWorker
  include ::Sidekiq::Worker

  def perform(invite_id)
    NotificationsMailer
      .invite(find_invite(invite_id))
      .deliver
  end

  private
  def find_invite(invite_id)
    UserInvitation.find(invite_id)
  end

end
