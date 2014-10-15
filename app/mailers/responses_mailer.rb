class ResponsesMailer < ApplicationMailer

  def submitted(response)
    assessment        = response.responder.assessment
    facilitator_email = assessment.user.email

    @full_name           = assessment.user.name
    @participant_name    = response.responder.user.name
    @dashboard_link      = assessment_url(assessment.id)
    @assessment_name     = assessment.name
    @district_name       = assessment.district.name
    @completed_num       = assessment.participant_responses.count
    @participant_count   = assessment.participants.count

    mail(to: facilitator_email)
  end

  private
  def assessment_url(id)
    "#{ENV['BASE_URL']}/#/assessments/#{id}/dashboard"
  end


end
