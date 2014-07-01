class V1::InvitationsController < ApplicationController
  def redeem
    invitation = find_invitation(params[:token])
    not_found and return unless invitation

    resource = User.find_for_database_authentication(email: invitation.email)
    if resource
      sign_in(:user, resource)
      render nothing: true
    else
      render nothing: true, status: 401
    end 
  end

  private
  def not_found
    render nothing: true, status: 404
  end

  def find_invitation(token)
    UserInvitation.find_by(token: token)
  end
end
