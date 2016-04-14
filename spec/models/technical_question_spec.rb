# == Schema Information
#
# Table name: technical_questions
#
#  id               :integer          not null, primary key
#  platform         :text             default([]), is an Array
#  hosting          :text
#  connectivity     :text
#  single_sign_on   :text
#  created_at       :datetime
#  updated_at       :datetime
#  product_entry_id :integer
#

require 'spec_helper'

describe TechnicalQuestion do

  it { is_expected.to belong_to(:product_entry) }

  describe '#save' do
    subject { FactoryGirl.create(:technical_question) }

    it { expect(subject.new_record?).to be false }
  end
end
