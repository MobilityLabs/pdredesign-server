# == Schema Information
#
# Table name: usage_questions
#
#  id               :integer          not null, primary key
#  school_usage     :text
#  usage            :text
#  vendor_data      :text
#  notes            :text
#  created_at       :datetime
#  updated_at       :datetime
#  product_entry_id :integer
#

require 'spec_helper'

describe UsageQuestion do
  it { is_expected.to belong_to(:product_entry) }

  describe '#save' do
    subject { FactoryGirl.create(:usage_question) }

    it { expect(subject.new_record?).to be false }
  end
end
