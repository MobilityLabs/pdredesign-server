class V1::InventoriesController < ApplicationController

  before_action :authenticate_user!

  def index
    @inventories = current_user.inventories
  end

  def show
    @inventory = Inventory.where(id: params[:id]).first
    unless @inventory
      render nothing:true, status: :not_found
      return
    end
    authorize_action_for @inventory
  end

  def create
    @inventory = Inventory.new
    authorize_action_for @inventory
    @inventory.name = inventory_params[:name]
    unless inventory_params[:deadline].blank?
      begin
        @inventory.deadline = DateTime.strptime(inventory_params[:deadline], '%m/%d/%Y')
      rescue
        @inventory.errors.add(:deadline, 'must be in MM/DD/YYYY format')
        return render_error
      end
    end
    @inventory.district = District.find(inventory_params[:district][:id])
    @inventory.owner = current_user
    if @inventory.save
      render template: 'v1/inventories/show'
    else
      render_error
    end
  end

  def update
    @inventory = Inventory.find(params[:id])
    authorize_action_for @inventory

    saved = @inventory.update(inventory_params)
    if saved
      @inventory.send_invites
      render nothing: true
    else
      render_error
    end
  end

  def district_product_entries
    @product_entries = ProductEntry.for_district(params[:id])

    render template: 'v1/product_entries/index'
  end

  private
  def inventory_params
    params.require(:inventory).permit(:name, :deadline, :district_id, district: [:id])
  end

  def render_error
    render json: {
        errors: @inventory.errors,
    }, status: :bad_request
  end
end
