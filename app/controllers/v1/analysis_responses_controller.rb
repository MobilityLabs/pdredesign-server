class V1::AnalysisResponsesController < ApplicationController
  before_action :authenticate_user!

  def create
    @response = Response.find_or_create_by(responder: analysis)
    authorize_action_for @response

    @response.rubric = analysis.rubric
    if @response.save
      create_empty_scores(@response)
      head :created
    else
      head :bad_request
    end
  end

  def show
    @response = Response.where(id: params[:id]).first
    if @response
      authorize_action_for @response
      @rubric = @response.rubric
      @categories = @response.categories
    else
      not_found
    end
  end

  private
  def analysis
    Analysis.where(id: params[:analysis_id]).first
  end
end
