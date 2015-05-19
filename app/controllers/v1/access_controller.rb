class V1::AccessController < ApplicationController
  before_action :authenticate_user!

  def grant
    @record  = find_access_request
    status(404) and return unless @record
    status(401) and return unless allowed?(@record)

    grant_access(@record)
    send_granted_notification(@record)
    render nothing: true
  end

  private
  def grant_access(record)
    assessment = record.assessment
    permission = Assessments::Permission.new(assessment)

    permission.accept_permission_requested(record.user)
  end

  #TODO: extract to authorizer
  def allowed?(record)
    record.assessment.facilitator?(current_user) 
  end

  def find_access_request
    AccessRequest.find_by(token: params[:token])
  end

  def send_granted_notification(record)
    AccessGrantedNotificationWorker.perform_async(record.assessment.id, record.user.id)
  end
end
