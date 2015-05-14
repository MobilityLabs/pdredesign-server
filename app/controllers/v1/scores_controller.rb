class V1::ScoresController < ApplicationController
  before_action :authenticate_user!

  def create
    authorize_action_for user_response

    score = find_or_initialize
    score.update_attributes(score_params)
    status(200) and return if score.save

    @errors = score.errors
    render 'v1/shared/errors', status: 422
  end

  def index
    @rubric        = assessment.rubric
    @user_response = user_response
    @questions = []

    user_response.categories.each do |category|
      category.rubric_questions(@rubric).each do |question|
        @questions << question
      end
    end
  end

  private
  def find_or_initialize
    Score.find_or_initialize_by(
      response_id: params[:response_id],
      question_id: params[:question_id])
  end

  def score_params
    params.permit(:response_id, :question_id, :value, :evidence)
  end

  def user_response
    Response.find(params[:response_id])
  end

  def assessment
    Assessment.find(params[:assessment_id])
  end

end

