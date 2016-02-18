class V1::SharedPrioritiesController < ApplicationController
  before_filter :load_assessment!

  def index
    @diagnostic_min = 2
    @categories     = categories
    render 'v1/priorities/index'
  end

  private
  def categories 
    @categories ||= Assessments::Priority
      .new(assessment)
      .categories
  end

  def assessment
    @assessment ||= Assessment.where(share_token: request_share_token).first
  end

  def load_assessment!
    return true if assessment
    render nothing: true, status: :not_found
  end

  def request_share_token
    params[:shared_id]
  end
end
