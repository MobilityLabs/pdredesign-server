require 'spec_helper'

describe InventoryAccessRequestMailer do
  describe '#request_access' do
    let(:inventory) { FactoryGirl.create(:inventory, :with_facilitators, facilitators: 2) }
    let(:access_request) { FactoryGirl.create(:inventory_access_request, :as_facilitator, inventory: inventory) }
    let(:subject) { InventoryAccessRequestMailer }

    it 'sends the email to the correct email' do
      mail = subject.request_access(access_request, 'test@example.com')
      expect(mail.to).to include('test@example.com')
    end

    it 'containers the correct link' do
      mail = subject.request_access(access_request, 'test@example.com')
      expect(mail.body).to include('/#/inventories/grant/' + access_request.token)
    end
  end
end
