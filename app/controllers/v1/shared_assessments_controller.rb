class V1::SharedAssessmentsController < ApplicationController
  before_action :load_assessment!

  def show
    render 'v1/assessments/shared'
  end

  private
  def assessment
    @assessment ||= Assessment.where(share_token: request_share_token).first
  end

  def load_assessment!
    return true if assessment
    render nothing: true, status: :not_found
  end

  def request_share_token
    params[:id]
  end
end
