class AllParticipantsNotificationWorker
  include ::Sidekiq::Worker

  def perform(assessment_id)
    assessment = Assessment.find(assessment_id)

    assessment.participants.each do |participant|
      AssessmentsMailer
        .assigned(assessment, participant.user.email)
        .deliver
    end
  end

end
