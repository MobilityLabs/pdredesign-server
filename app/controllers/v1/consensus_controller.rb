class V1::ConsensusController < V1::ResponsesController
  before_action :authenticate_user!

  def create
    @response = Response.find_or_initialize_by(
        responder_type: 'Assessment',
        responder_id: assessment.id,
        rubric: assessment.rubric)

    authorize_action_for @response
    @response.save
  end

  def update
    authorize_action_for assessment
    @response = find_response

    if consensus_params[:submit]
      @response.update(submitted_at: Time.now)
    end

    head :ok
  end

  def show
    @response = find_response

    if @response
      @rubric = assessment.rubric
      @categories = @response.categories
      @team_role = params[:team_role]
      @team_roles = assessment.team_roles_for_participants

      authorize_action_for @response
    else
      not_found
    end
  end

  def evidence
    @assessment = assessment
    @answered_scores = @assessment.answered_scores.where(question_id: params[:question_id])
    authorize_action_for @assessment
  end

  authority_actions evidence: 'read'

  private
  def consensus_params
    params.permit :submit
  end

  def find_response
    Response.find_by(responder_type: 'Assessment', id: params[:id])
  end

end

