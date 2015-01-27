class SignupNotificationWorker
  include ::Sidekiq::Worker

  def perform(user_id)
    user = find_user(user_id)

    NotificationsMailer
      .signup(user)
      .deliver_now
  end

  private
  def find_user(user_id)
    User.find(user_id)
  end

end
