class V1::ParticipantsController < ApplicationController
  before_action :authenticate_user!
  authorize_actions_for :assessment

  def create
    params      = participant_params
    send_invite = params.delete(:send_invite) 
    participant = Participant.create!(params)

    send_participant_assigned_email(assessment, participant) if send_invite
    render nothing: true
  end
  authority_actions create: 'update'

  def destroy
    participant = Participant.find_by(participant_params)
    if participant
      participant.destroy
      render nothing: true
    else
      not_found
    end
  end

  def index
    @participants = assessment.participants 
  end

  def all
    @users = users_from_district(assessment) 
  end
  authority_actions all: 'update'

  def mail
    participant = Participant.find_by(id: params[:participant_id]) 
    not_found and return unless participant 

    invite_record = invitation_record(assessment.id, participant.user.id)

    if(invite_record)
      mailer = invite_mailer(invite_record)
    else
      mailer = assessments_mailer(assessment, participant)
    end

    render text: mailer.text_part.body
  end
  authority_actions mail: 'update'

  protected

  def invitation_record(assessment_id, user_id)
    UserInvitation.find_by(assessment_id: assessment_id, user_id: user_id)
  end

  def send_participant_assigned_email(assessment, participant) 
    assessments_mailer(assessment, participant).deliver_now
  end

  def invite_mailer(record)
    NotificationsMailer.invite(record)
  end
 
  def assessments_mailer(assessment, participant)
    AssessmentsMailer.assigned(assessment, participant)
  end

  def users_from_district(assessment)
    district_id = assessment.district_id
    user_ids    = assessment.participants.pluck(:user_id)
    
    users = User
      .includes(:districts)
      .where(districts: { id: district_id})
      .where.not(id: user_ids)
      .reject { |u| u.role.to_sym == :network_partner }
  end

  def participant_params
    params.permit(:assessment_id, :user_id, :id, :send_invite)
  end

  def assessment
    Assessment.find(params[:assessment_id])
  end
end
