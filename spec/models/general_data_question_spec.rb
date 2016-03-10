# == Schema Information
#
# Table name: general_data_questions
#
#  id                          :integer          not null, primary key
#  subcategory                 :string
#  point_of_contact_name       :string
#  point_of_contact_department :string
#  data_capture                :string
#  created_at                  :datetime
#  updated_at                  :datetime
#  data_entry_id               :integer
#

require 'spec_helper'

describe GeneralDataQuestion do
  it {is_expected.to belong_to(:data_entry) }

  describe '#save' do
    subject { FactoryGirl.create(:general_data_question) }

    it { expect(subject.new_record?).to be false }
  end
end
