require 'spec_helper'

describe InventoryAccessRequestNotificationWorker do
  context 'inventory with two facilitators' do
    let(:subject) { InventoryAccessRequestNotificationWorker }
    let(:inventory) { FactoryGirl.create(:inventory, :with_facilitators, facilitators: 2) }
    let(:request) { FactoryGirl.create(:inventory_access_request, :as_facilitator, inventory: inventory) }
    let(:all_facilitators) { inventory.facilitators.collect(&:user) }

    it 'sends an email to all facilitators' do
      double = double('mailer')
      all_facilitators.each do |facilitator|
        expect(InventoryAccessRequestMailer).to receive(:request_access)
          .with(request, facilitator.email)
          .and_return(double)
      end

      expect(double).to receive(:deliver_now).exactly(all_facilitators.count).times
      subject.new.perform(request.id)
    end
  end
end
