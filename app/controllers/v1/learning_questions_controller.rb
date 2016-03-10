class V1::LearningQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_assessment, only: [:index, :create, :exists]

  def index
    if assessment_includes_current_user?
      @learning_questions = LearningQuestion.where(assessment: @assessment).order(created_at: :asc)
      render 'v1/learning_questions/index'
    else
      @errors = 'You are not a part of this assessment, so you cannot see any learning questions.'
      render 'v1/shared/errors', status: :bad_request
    end
  end

  def create
    if assessment_includes_current_user?
      @learning_question = LearningQuestion.new(learning_question_params)
      @learning_question.assessment = @assessment
      @learning_question.user = current_user
      if @learning_question.save
        render 'v1/learning_questions/show'
      else
        @errors = @learning_question.errors
        render 'v1/shared/errors', status: :bad_request
      end
    else
      @errors = 'User is not a part of this assessment'
      render 'v1/shared/errors', status: :bad_request
    end
  end

  def update
    learning_question = LearningQuestion.find(params[:id])
    if learning_question.user != current_user
      @errors = 'You may not edit a learning question that you did not create.'
      return render 'v1/shared/errors', status: :bad_request
    end
    learning_question.body = learning_question_params[:body]
    if learning_question.save
      render nothing: true, status: :no_content
    else
      @errors = learning_question.errors
      render 'v1/shared/errors', status: :bad_request
    end
  end

  def destroy
    learning_question = LearningQuestion.find(params[:id])
    if learning_question.user == current_user
      learning_question.destroy
      render nothing: true, status: :no_content
    else
      @errors = 'You may not delete a learning question that does not belong to you.'
      render 'v1/shared/errors', status: :bad_request
    end
  end

  def exists
    has_created_question = LearningQuestion.where(user: current_user, assessment: @assessment).exists?
    if has_created_question
      render nothing: true, status: :ok
    else
      render nothing: true, status: :not_found
    end
  end

  private
  def learning_question_params
    params.require(:learning_question).permit(:body)
  end

  def fetch_assessment
    @assessment = Assessment.find(params[:assessment_id])
  end

  def assessment_includes_current_user?
    @assessment.user == current_user || @assessment.users.include?(current_user)
  end
end
