class InventoryAccessRequestMailer < ApplicationMailer
  def request_access(request, email)
    @access_link = access_link(request.token)
    @requestor_name = request.user.name
    @role = request.role
    @nventory_name = request.inventory.name
    mail(to: email)
  end

  private
  def access_link(token)
    "#{ENV['BASE_URL']}/#/inventories/grant/#{token}"
  end
end

