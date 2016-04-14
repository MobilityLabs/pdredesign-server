# == Schema Information
#
# Table name: inventory_invitations
#
#  id           :integer          not null, primary key
#  first_name   :string
#  last_name    :string
#  email        :string
#  team_role    :string
#  role         :string
#  token        :string
#  inventory_id :integer          not null
#  user_id      :integer
#

require 'spec_helper' 

describe InventoryInvitation do
  subject { FactoryGirl.create(:inventory_invitation) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:inventory) }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_presence_of :inventory_id }
  it { is_expected.to validate_uniqueness_of(:email).scoped_to(:inventory_id).with_message('User has already been invited').ignoring_case_sensitivity }
end
