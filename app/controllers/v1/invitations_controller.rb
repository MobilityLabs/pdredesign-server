class V1::InvitationsController < ApplicationController
  def redeem
    not_found and return unless invitation
    unauthorized and return unless invited_user

    sign_in(:user, invited_user)

    if invited_user.update(permitted_params)
      invitation.destroy
      status 200
    else
      @errors = invited_user.errors
      render 'v1/shared/errors', status: 422
    end
  end

  def show
    not_found and return unless invitation
    unauthorized and return unless invited_user

    locals = {
        user: invited_user
    }
    case invitation.class.to_s
      when InventoryInvitation.to_s
        locals[:inventory_id] = invitation.inventory_id
      when UserInvitation.to_s
        locals[:assessment_id] = invitation.assessment_id
      when AnalysisInvitation.to_s
        locals[:inventory_id] = invitation.analysis.inventory.id
        locals[:analysis_id] = invitation.analysis_id
      else
        raise 'Invitation not valid'
    end

    render :show, locals: locals
  end

  private
  def permitted_params
    params.permit :first_name,
                  :last_name,
                  :email,
                  :password,
                  :team_role
  end

  def invited_user
    @invited_user ||= User.find_for_database_authentication(email: invitation.email)
  end

  def invitation
    @invitation ||= find_invitation(params[:token])
  end

  def find_invitation(token)
    UserInvitation.find_by(token: token) ||
        InventoryInvitation.find_by(token: token) ||
        AnalysisInvitation.find_by(token: token)
  end

end
