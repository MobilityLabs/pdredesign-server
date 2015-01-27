class PasswordResetNotificationWorker
  include ::Sidekiq::Worker

  def perform(user_id)
    user = find_user(user_id)
    PasswordResetMailer.reset(user).deliver_now
  end

  private
  def find_user(id)
    User.find(id)
  end
end
