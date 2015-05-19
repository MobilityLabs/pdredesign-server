class V1::AccessRequestController < ApplicationController
  before_action :authenticate_user!

  def create

    @request = Assessments::Permission.request_access(
      user: current_user, 
      assessment_id: request_params[:assessment_id],
      roles: request_params[:roles])

    if(@request.save)
      queue_job
      render json: @request
    else
      @errors = @request.errors
      render 'v1/shared/errors', errors: @errors, status: 422
    end
  end

  private
  def queue_job
    AccessRequestNotificationWorker.perform_async(@request.id)
  end

  def request_params
    params.permit(:assessment_id, roles: [])
  end

  def assessment
    Assessment.find(params[:assessment_id])
  end
end
 
