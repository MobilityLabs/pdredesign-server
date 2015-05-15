class V1::AssessmentsPermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :assessment, only: [:show, :update]

  def index
    render nothing: true
  end

  def show
    render nothing: true
  end

  def update
    render nothing: true
  end
  private

  def assessment
    @assessment = Assessment.find(params[:assessment_id])
    authorize_action_for @assessment
  end
end