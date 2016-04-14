class V1::SharedReportController < V1::ReportController
  skip_before_action :authenticate_user!
  skip_before_action :authorize_assessment!

  before_filter :load_assessment!
  delegate :axis_questions, to: :report
  delegate :average, to: :report
  
  private
  def assessment
    @assessment ||= Assessment.where(share_token: request_share_token).first
  end

  def load_assessment!
    return true if assessment
    render nothing: true, status: :not_found
  end

  def request_share_token
    params[:shared_token]
  end
end
