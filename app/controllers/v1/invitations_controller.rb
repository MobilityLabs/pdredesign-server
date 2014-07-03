class V1::InvitationsController < ApplicationController
  def redeem
    not_found    and return unless invitation
    unauthorized and return unless found_user

    sign_in(:user, found_user)

    status 200
  end

  private
  def found_user
    @found_user ||= User.find_for_database_authentication(email: invitation.email)
  end

  def invitation
    @invitation ||= find_invitation(params[:token])
  end

  def find_invitation(token)
    UserInvitation.find_by(token: token)
  end

end
