class AccessRequestMailer < ApplicationMailer

  def request_access(record, email)
    @access_link     = access_link(record.token)
    @requestor_name  = record.user.name
    @roles           = record.roles.join(",")
    @assessment_name = record.assessment.name
    mail(to: email)
  end

  private
  def access_link(token)
    "#{ENV['BASE_URL']}/#/grant/#{token}"
  end

end

