# == Schema Information
#
# Table name: inventory_access_requests
#
#  id           :integer          not null, primary key
#  inventory_id :integer          not null
#  user_id      :integer          not null
#  role         :string           not null
#  token        :string
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper' 

describe InventoryAccessRequest do
  subject { FactoryGirl.create(:inventory_access_request, :as_facilitator) }
  it { is_expected.to belong_to(:inventory) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of :inventory_id }
  it { is_expected.to validate_presence_of :user_id }
  it { is_expected.to validate_presence_of :role }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:inventory_id).with_message('User has already requested access').ignoring_case_sensitivity }
  it { expect(subject.token).not_to be_empty }
end
