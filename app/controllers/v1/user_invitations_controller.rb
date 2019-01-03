class V1::UserInvitationsController < ApplicationController
  before_action :authenticate_user!
  authorize_actions_for :assessment

  def create
    create_params = user_invitiation_params
    create_params[:assessment_id] = params[:assessment_id]

    send_invite = create_params.delete(:send_invite)
    invite = UserInvitation.new(create_params)

    if invite.save

      Invitation::InsertFromInvite
        .new(invite)
        .execute

      queue_worker(invite.id) if send_invite
      head :ok
    else
      @errors = invite.errors.messages
      render 'v1/shared/errors', status: 422
    end
  end

  authority_actions create: 'update'

  private
  def queue_worker(invite_id)
    UserInvitationNotificationWorker.perform_async(invite_id)
  end

  def user_invitiation_params
    params
      .permit(:first_name, :last_name, :email, :send_invite, :team_role, :role)
  end

  def assessment
    Assessment
      .find(params[:assessment_id])
  end

end
