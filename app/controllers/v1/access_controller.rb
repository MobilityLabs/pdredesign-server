class V1::AccessController < ApplicationController
  before_action :authenticate_user!

  def grant
    @record  = find_access_request
    status(404) and return unless @record
    status(401) and return unless allowed?(@record)

    grant_access(@record)
  end

  private
  def grant_access(record)
    assessment = record.assessment
    permission = Assessments::Permission.new(assessment)

    permission.accept_permission_requested(record.user)
  end

  def allowed?(record)
    auth = AssessmentAuthorizer.new(record.assessment)
    auth.updatable_by?(current_user)
  end

  def find_access_request
    AccessRequest.find_by(token: params[:token])
  end
end
