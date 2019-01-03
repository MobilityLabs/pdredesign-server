module SharedInventoryFetch
  extend ActiveSupport::Concern

  def inventory
    id = params[:inventory_id] || params[:id]
    @inventory = Inventory.where('inventories.id = ? OR inventories.share_token = ?', id.to_i, id).first
    unless @inventory
      head :not_found
      return nil
    end
    unless @inventory.share_token == id
      authenticate_user!
      authorize_action_for @inventory
    end
    @inventory
  end
end
