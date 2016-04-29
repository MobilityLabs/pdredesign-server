class V1::InventoriesController < ApplicationController
  include SharedInventoryFetch
  before_action :authenticate_user!, except: :show

  def index
    @inventories = Inventory.where(district_id: current_user.districts)
  end

  def show
    @inventory = inventory
    @messages = messages
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
    @inventory = inventory
    authorize_action_for inventory

    saved = @inventory.update(inventory_params)
    if saved
      if inventory_params[:assign]
        AllInventoryParticipantsNotificationWorker.perform_async(@inventory.id)
      end
      render nothing: true, status: :no_content
    else
      render_error
    end
  end

  def district_product_entries
    @product_entries = ProductEntry.for_district(params[:id])

    render template: 'v1/product_entries/index'
  end

  def mark_complete
    member = inventory.members.where(user: current_user).first
    response = InventoryResponse.find_or_create_by(inventory_member: member)
    response.submitted_at = Time.parse(params[:submitted_at])

    if response.save
      render nothing: true
    else
      render json: {
          errors: response.errors,
      }, status: :bad_request
    end
  end

  def save_response
    member = inventory.members.where(user: current_user).first
    response = InventoryResponse.find_or_create_by(inventory_member: member)
    if response.save
      render nothing: true
    else
      render json: {
          errors: response.errors,
          status: :bad_request
      }
    end
  end

  def participant_response
    member = inventory.members.where(user: current_user).first
    render json: {
        hasResponded: member.has_responded?
    }, status: :ok
  end

  private
  def inventory_params
    params.require(:inventory).permit(:name, :deadline, :district_id, :message, :assign, :submitted_at, district: [:id])
  end

  def render_error
    render json: {
        errors: @inventory.errors,
    }, status: :bad_request
  end

  def messages
    messages = []
    messages.concat inventory.messages
    messages.push welcome_message
  end

  def welcome_message
    OpenStruct.new(id: nil,
                   category: 'welcome',
                   sent_at: inventory.updated_at,
                   teaser: inventory.message)
  end
end
