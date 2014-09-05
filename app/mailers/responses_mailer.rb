class ResponsesMailer < ApplicationMailer

  def submitted(response)
    assessment        = response.responder.assessment
    facilitator_email = assessment.user.email

    @participant_name    = response.responder.user.name
    @assessment_url      = assessment_url(assessment.id)
    @assessment_name     = assessment.name
    @assessment_district = assessment.district.name
    @assessment_completed_percent = assessment.percent_completed
    @assessment_completed_count   = assessment.participant_responses.count
    @assessment_participant_count = assessment.participants.count
    @assessment_due               = assessment.due_date.in_time_zone("Eastern Time (US & Canada)").strftime("%B %d, %Y") 
    @facilitator_name             = assessment.user.name

    mail(to: facilitator_email)
  end

  private
  def assessment_url(id)
    "#{ENV['BASE_URL']}/#/assessments/#{id}/dashboard"
  end


end
