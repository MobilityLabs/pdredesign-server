# == Schema Information
#
# Table name: inventory_members
#
#  id           :integer          not null, primary key
#  inventory_id :integer          not null
#  user_id      :integer          not null
#  created_at   :datetime
#  updated_at   :datetime
#  invited_at   :datetime
#  role         :string
#

require 'spec_helper'

describe InventoryMember do
  it { is_expected.to validate_presence_of :inventory }
  it { is_expected.to validate_presence_of :user }
  it { is_expected.to belong_to(:inventory) }
  it { is_expected.to belong_to(:user) }
end
