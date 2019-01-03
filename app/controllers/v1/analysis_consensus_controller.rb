class V1::AnalysisConsensusController < ApplicationController
  before_action :authenticate_user!

  def create
    @response = Response.find_or_initialize_by(responder: fetch_analysis, rubric: fetch_analysis.rubric)
    authorize_action_for @response
    @response.save
  end

  def update
    authorize_action_for fetch_analysis
    @response = fetch_response

    if consensus_params[:submit].present?
      @response.update(submitted_at: Time.now)
    end

    head :ok
  end
  authority_actions update: :read

  def show
    @response = fetch_response
    if @response.present?
      authorize_action_for @response
      @rubric = fetch_response.responder.rubric
      @categories = fetch_response.categories
      @team_role = params[:team_role]
      @team_roles = fetch_response.responder.team_roles_for_participants
      respond_to do |format|
        format.json { render template: 'v1/analysis_consensus/show', status: 200 }
        format.csv  { render csv: 'analysis_consensus', template: 'v1/analysis_consensus/show' }
      end
    else
      head :not_found
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
