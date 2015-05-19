class V1::AssessmentsPermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :assessment, only: [:show, :update, :current_level]

  def index
    render nothing: true
  end

  def show
    render nothing: true
  end

  def update
    params[:permissions].each{ |permission| update_permission(permission) }

    render nothing: true
  end

  def current_level
    respond_to do |format|
      format.json do
        render json: { permission_level: assessment_permission.get_level(current_user) }
      end
    end
  end
  private

  def update_permission(permission)
    user = User.find_by(email: permission[:email])
    assessment_permission.add_level(user, permission[:level])
  end

  def assessment_permission
    Assessments::Permission.new(@assessment)
  end

  def assessment
    @assessment = Assessment.find(params[:assessment_id])
    authorize_action_for @assessment
  end
end