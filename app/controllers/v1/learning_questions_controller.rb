class V1::LearningQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :fetch_tool, only: [:index, :create, :exists]

  def index
    if tool_includes_current_user?
      @learning_questions = LearningQuestion.where(tool: @tool).order(created_at: :asc)
      render 'v1/learning_questions/index'
    else
      @errors = 'You are not a part of this assessment, so you cannot see any learning questions.'
      render 'v1/shared/errors', status: :bad_request
    end
  end

  def create
    if tool_includes_current_user?
      @learning_question = LearningQuestion.new(learning_question_params)
      @learning_question.tool = @tool
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
      head :no_content
    else
      @errors = learning_question.errors
      render 'v1/shared/errors', status: :bad_request
    end
  end

  def destroy
    learning_question = LearningQuestion.find(params[:id])
    if learning_question.user == current_user
      learning_question.destroy
      head :no_content
    else
      @errors = 'You may not delete a learning question that does not belong to you.'
      render 'v1/shared/errors', status: :bad_request
    end
  end

  def exists
    has_created_question = LearningQuestion.where(user: current_user, tool: @tool).exists?
    if has_created_question
      head :ok
    else
      head :not_found
    end
  end

  private
  def learning_question_params
    params.require(:learning_question).permit(:body)
  end

  def fetch_tool
    if params[:analysis_id]
      @tool = Analysis.find(params[:analysis_id])
    elsif params[:inventory_id]
      @tool = Inventory.find(params[:inventory_id])
    elsif params[:assessment_id]
      @tool = Assessment.find(params[:assessment_id])
    end
  end

  def tool_includes_current_user?
    case @tool.class.to_s
      when 'Assessment'
        @tool.user == current_user || @tool.users.include?(current_user)
      when 'Inventory'
        @tool.member?(current_user)
      when 'Analysis'
        @tool.member?(current_user)
    end
  end
end
