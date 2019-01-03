class V1::ScoresController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_response
  after_action :flush_assessment_cache, only: [:create]

  helper_method :fetch_score

  def create
    authorize_action_for @response

    score = Score.find_or_initialize_by(response_id: response_id, question_id: params[:question_id])
    score.update_attributes(score_params)
    score_existed_prior = score.id.present?
    if score.save
      head (score_existed_prior ? :no_content : :created)
    else
      @errors = score.errors
      render 'v1/shared/errors', status: :unprocessable_entity
    end
  end

  def index
    @rubric = fetch_responder.rubric
    @questions = []

    @response.categories.each do |category|
      category.rubric_questions(@rubric).each do |question|
        @questions << question
      end
    end
  end

  def fetch_score(question:, response:)
    Score.includes(:supporting_inventory_response).where(question: question, response: response).first
  end

  private
  def score_params
    params.permit(
      :response_id,
      :question_id,
      :value,
      :evidence,
      supporting_inventory_response_attributes: [
        :id,
        {product_entries: []},
        {data_entries: []},
        :product_entry_evidence,
        :data_entry_evidence
      ])
  end

  def response_id
    params[:response_id] || params[:analysis_response_id]
  end

  def fetch_response
    @response ||= Response.where(id: response_id).first
  end

  def fetch_responder
    if params[:assessment_id]
      Assessment.where(id: params[:assessment_id]).first
    elsif params[:analysis_id]
      Analysis.where(id: params[:analysis_id]).first
    end
  end

  def flush_assessment_cache
    fetch_responder.try(:flush_cached_version)
  end
end

