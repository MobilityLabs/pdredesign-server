require 'spec_helper'

describe InventoryAccessGrantedNotificationWorker do
  let(:inventory) { FactoryGirl.create(:inventory) }
  let(:user) { FactoryGirl.create(:user) }

  describe '#perform' do
    let(:mailer) { double('mailer') }

    it 'sends an email notification on notify method' do
      expect(InventoryAccessGrantedMailer).to receive(:notify)
        .with(inventory, user, 'facilitator')
        .and_return(mailer)
      expect(mailer).to receive(:deliver_now)
      InventoryAccessGrantedNotificationWorker.new.perform(inventory.id, user.id, 'facilitator')
    end
  end
end
