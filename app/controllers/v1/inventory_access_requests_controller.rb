class V1::InventoryAccessRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :inventory

  def index
    @requests = inventory.access_requests
  end

  def create
    permission = Inventories::Permission.new(inventory: inventory, user: current_user)
    @request = permission.request_access(role: create_request_params[:role])
    if @request.new_record?
      @errors = @request.errors
      render 'v1/shared/errors', errors: @errors, status: 422
      return
    end
    render json: @request
  end

  def update
    unless access_request
      return render status: :not_found, nothing: true
    end
    permission = Inventories::Permission.new(inventory: inventory, user: access_request.user)
    case update_request_params[:status]
    when 'denied'
      permission.deny
    when 'accepted'
      permission.accept
    end
    render nothing: true
  end

  private
  def inventory_id
    params[:inventory_id]
  end

  def inventory
    @inventory ||= Inventory.find(inventory_id)
  end

  def create_request_params
    params.permit(:role)
  end

  def update_request_params
    params.permit(:status)
  end

  def access_request_id
    params[:id]
  end

  def access_request
    @access_request ||= inventory.access_requests.where(id: access_request_id).first
  end
end
 
