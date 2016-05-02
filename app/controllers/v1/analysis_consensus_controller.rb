class V1::AnalysisConsensusController < ApplicationController
  before_action :authenticate_user!

  def create
    response = Response.find_or_initialize_by(responder: fetch_analysis, rubric: fetch_analysis.rubric)
    authorize_action_for response
    response.save
  end

  def update
    authorize_action_for fetch_analysis
    @response = response

    if consensus_params[:submit]
      @response.update(submitted_at: Time.now)
    end

    render nothing: true
  end

  def show
    @response = fetch_response
    if @response.present?
      authorize_action_for @response
      @rubric = fetch_response.responder.rubric
      @categories = fetch_response.categories
      @team_role = params[:team_role]
      @team_roles = fetch_response.responder.team_roles_for_participants
    else
      render nothing: true, status: :not_found
    end
  end

  private
  def consensus_params
    params.permit(:submit)
  end

  def fetch_response
    @response ||= Response.where(id: params[:id]).first
  end

  def fetch_analysis
    @analysis ||= Analysis.where(id: params[:analysis_id]).first
  end
end
