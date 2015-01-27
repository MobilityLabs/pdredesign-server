class AccessRequestNotificationWorker
  include ::Sidekiq::Worker

  def perform(access_request_id)
    request    = AccessRequest.find(access_request_id)
    assessment = ::Assessment.find(request.assessment_id)

    facilitators(assessment).uniq.each do |facilitator|
      ::AccessRequestMailer
        .request_access(request, facilitator.email)
        .deliver_now
    end
  end

  private
  def facilitators(assessment)
    [assessment.user] + assessment.facilitators
  end

end
