class V1::InventoryInvitablesController < ApplicationController
  before_action :authenticate_user!
  authorize_actions_for :inventory

  authority_actions index: 'read'
  def index
    member_users = inventory.members.select(:user_id).map(&:user_id)
    @users = User.joins(:districts)
      .where(districts:{id: inventory.district_id})
      .where.not(id: member_users, role: 'network_partner')
  end

  private
  def inventory_id
    params[:inventory_id]
  end

  def inventory
    @inventory ||= Inventory.find(inventory_id)
  end
end
