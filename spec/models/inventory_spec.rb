require 'spec_helper'

describe Inventory do
  it { is_expected.to have_one(:product_entry) }
  it { is_expected.to have_one(:data_entry) }

  it { is_expected.to accept_nested_attributes_for(:product_entry) }
  it { is_expected.to accept_nested_attributes_for(:data_entry) }
end