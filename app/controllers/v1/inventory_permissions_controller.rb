class V1::InventoryPermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :inventory

  def show
    @users = inventory.members.includes(:user).map(&:user)
  end

  def update
    if params[:permissions]
      params[:permissions].each{ |permission| update_permission(permission) }
    end
    render nothing: true
  end

  private
  def update_permission(permission)
    user = User.find_by(email: permission["email"])
    role = permission["role"]
    role = "facilitator" if user.network_partner?
    permission = Inventories::Permission.new(inventory: inventory, user: user)
    permission.role = role
  end

  def inventory
    @inventory ||= Inventory.find(params[:inventory_id])
  end
end
