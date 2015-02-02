class AllParticipantsNotificationWorker
  include ::Sidekiq::Worker

  def perform(assessment_id)
    assessment = Assessment.find(assessment_id)
    assessment.participants.each do |participant|
      next if invited_participant?(participant)
      record = invite_record(assessment_id, participant)
      
      if record
        send_invitation_email(record)
      else
        send_assessment_mail(assessment, participant)
      end
      
      mark_invited(participant)
    end
  end

  private
  def mark_invited(participant)
    participant.update(invited_at: Time.now)
  end

  def send_invitation_email(invitation_record)
    NotificationsMailer
      .invite(invitation_record)
      .deliver_now
  end

  def send_assessment_mail(assessment, participant)
    AssessmentsMailer
      .assigned(assessment, participant)
      .deliver_now
  end

  def invite_record(assessment_id, participant)
    UserInvitation.find_by(assessment_id: assessment_id,
                           user_id: participant.user.id) 
  end

  def invited_participant?(participant)
    participant.invited_at
  end

end
