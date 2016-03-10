# == Schema Information
#
# Table name: inventories
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  deadline    :datetime         not null
#  district_id :integer          not null
#

require 'spec_helper'

describe Inventory do
  it { is_expected.to have_many(:product_entries) }
  it { is_expected.to have_many(:data_entries) }
  it { is_expected.to belong_to(:district) }

  it { is_expected.to accept_nested_attributes_for(:product_entries) }
  it { is_expected.to accept_nested_attributes_for(:data_entries) }

  describe '#save' do
    subject { FactoryGirl.create(:inventory) }

    it { expect(subject.new_record?).to be false } 
  end
end
