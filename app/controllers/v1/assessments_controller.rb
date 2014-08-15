class V1::AssessmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @assessments = user_assessments
    @role        = user_role
  end

  def show
    @assessment = assessment
    authorize_action_for @assessment
    @messages   = messages
  end

  def update
    @assessment  = assessment
    authorize_action_for @assessment

    update_params = assessment_params
    if update_params[:assign]
      update_params.delete :assign
      update_params[:assigned_at] = Time.now
      invite_all_users(@assessment)
    end

    @assessment.update(update_params)
    render nothing: true
  end

  def create
    @assessment = Assessment.new(assessment_create_params)
    authorize_action_for @assessment

    @assessment.user        = current_user
    @assessment.district_id = current_user.district_ids.first
    @assessment.rubric_id   = pick_rubric unless @assessment.rubric_id

    if(assessment_create_params[:district_id])
      @assessment.district_id = assessment_create_params[:district_id]
    end

    if @assessment.save
      render :show
    else
      @errors = @assessment.errors
      render 'v1/shared/errors', status: 422
    end
  end

  private
  def invite_all_users(assessment)
    assessment.participants.update_all(invited_at: Time.now)
    AllParticipantsNotificationWorker.perform_async(assessment.id)
  end

  def pick_rubric
    Rubric.order("version ASC").first.id
  end

  def user_role
    if current_user.role.present?
      current_user.role.to_sym
    else
      :member
    end
  end

  def messages
    messages = []
    messages.concat assessment.messages
    messages.push welcome_message
  end

  def welcome_message
    OpenStruct.new(id: nil,
      category: "welcome", 
      sent_at:  assessment.updated_at,
      teaser:  assessment.message)
  end

  def assessment_create_params
    params.permit(:rubric_id, :name, :due_date, :district_id)
  end

  def assessment_params
    params.permit(:rubric_id, :name, :meeting_date, :due_date, :message, :assign, :district_id)
  end

  def assessment
    Assessment.find(params[:id])
  end

  def user_assessments(user = current_user)
    Assessment.assessments_for_user(user)
  end
end
