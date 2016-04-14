class V1::InventoryInvitationsController < ApplicationController
  before_action :authenticate_user!
  authorize_actions_for :inventory

  authority_actions create: 'update'
  def create
    create_params = invitation_params
    create_params[:inventory_id] = inventory_id

    invite = InventoryInvitation.new(create_params)

    unless invite.save
      @errors = invite.errors.messages
      render 'v1/shared/errors', status: 422
      return
    end

    Inventories::MemberFromInvite.new(invite).execute
    render nothing: true
  end

  private
  def invitation_params
    params
      .permit(:first_name, :last_name, :email, :team_role, :role)
  end

  def inventory_id
    params[:inventory_id]
  end

  def inventory
    Inventory.find(inventory_id)
  end
end
