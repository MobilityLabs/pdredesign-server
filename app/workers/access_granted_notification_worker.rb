class AccessGrantedNotificationWorker
  include ::Sidekiq::Worker

  def perform(assessment_id, user_id, role)
    asessment = find_assessment(assessment_id)
    user      = find_user(user_id)

    AccessGrantedMailer.notify(asessment, user, role).deliver_now
  end

  private
  def find_assessment(id)
  	Assessment.find(id)
  end

  def find_user(id)
  	User.find(id)
  end
end