class V1::UserInvitationsController < ApplicationController
  before_action :authenticate_user!
  authorize_actions_for :assessment

  def create
    create_params = user_invitiation_params
    create_params[:assessment_id] = params[:assessment_id]

    invite = UserInvitation.new(create_params)

    if invite.save
      UserInvitationNotificationWorker
        .perform_async(invite.id)
      render nothing: true
    else
      @errors = invite.errors.messages
      render 'v1/shared/errors', status: 422
    end
  end
  authority_actions create: 'update'

  private
  def user_invitiation_params
    params
      .permit(:first_name, :last_name, :email)
  end

  def assessment
    Assessment
      .find(params[:assessment_id])
  end

end
