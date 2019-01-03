class V1::AssessmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @assessments = user_assessments
    @role = user_role
  end

  def show
    @assessment = assessment
    authorize_action_for @assessment
  end

  def update
    @assessment = assessment
    authorize_action_for @assessment

    update_params = assessment_params

    @assessment.update(update_params)
    if @assessment.valid?
      if update_params[:assign]
        invite_all_users(@assessment)
      end
      head :ok
    else
      @errors = @assessment.errors
      render 'v1/shared/errors', status: :bad_request
    end
  end

  def create
    @assessment = Assessment.new(assessment_create_params)
    authorize_action_for @assessment

    @assessment.user = current_user
    @assessment.district_id = current_user.district_ids.first
    @assessment.rubric_id = pick_rubric unless @assessment.rubric_id

    if assessment_create_params[:district_id]
      @assessment.district_id = assessment_create_params[:district_id]
    end

    assign_current_user_as_participant(@assessment) if current_user.district_member?

    if @assessment.save
      ToolMember.create!(user: @assessment.user, tool: @assessment, roles: [ToolMember.member_roles[:facilitator]])
      render :show
    else
      @errors = @assessment.errors
      render 'v1/shared/errors', status: 422
    end
  end

  private
  def assign_current_user_as_participant(assessment)
    participant = Participant.create!(assessment: assessment, user: current_user)
    @assessment.participants << participant
  end

  def invite_all_users(assessment)
    AllParticipantsNotificationWorker.perform_async(assessment.id)
  end

  def pick_rubric
    Rubric.assessment_driven.where.not(version: nil).order(version: :desc).first.id
  end

  def user_role
    current_user.role.to_sym
  end

  def messages
    messages = []
    messages.concat assessment.messages
    messages.push welcome_message
  end

  def welcome_message
    OpenStruct.new(id: nil,
                   category: "welcome",
                   sent_at: assessment.updated_at,
                   teaser: assessment.message)
  end

  def assessment_create_params
    params.permit(:rubric_id, :name, :due_date, :district_id)
  end

  def assessment_params
    params.permit(:rubric_id, :name, :meeting_date, :due_date,
                  :message, :assign, :district_id, :report_takeaway)
  end

  def assessment
    Assessment.find(params[:id])
  end

  def user_assessments(user = current_user)
    Assessment.assessments_for_user(user)
  end

end
