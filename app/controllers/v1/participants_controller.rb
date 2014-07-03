class V1::ParticipantsController < ApplicationController
  before_action :authenticate_user!
  authorize_actions_for :assessment

  def create
    Participant.create!(participant_params)
    render nothing: true
  end
  authority_actions create: 'update'

  def destroy
    participant = Participant.find_by(participant_params)
    if participant
      participant.destroy
      render nothing: true
    else
      render status: 404, nothing: true
    end
  end

  def index
    @participants = assessment.participants 
  end

  def all
    @users = users_from_district(assessment) 
  end
  authority_actions all: 'create'

  protected
  def users_from_district(assessment)
    district_id = assessment.district_id
    user_ids    = assessment.participants.pluck(:user_id)
    
    User
      .includes(:districts)
      .where(districts: { id: district_id})
      .where.not(id: user_ids)
  end

  def participant_params
    params.permit(:assessment_id, :user_id, :id)
  end

  def assessment
    Assessment.find(params[:assessment_id])
  end
end
