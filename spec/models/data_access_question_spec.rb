# == Schema Information
#
# Table name: data_access_questions
#
#  id                   :integer          not null, primary key
#  data_storage         :text
#  who_access_data      :text
#  how_data_is_accessed :text
#  why_data_is_accessed :text
#  notes                :text
#  created_at           :datetime
#  updated_at           :datetime
#  data_entry_id        :integer
#

require 'spec_helper'

describe DataAccessQuestion do
  it { is_expected.to belong_to(:data_entry) }

  describe '#save' do
    subject { FactoryGirl.create(:data_access_question) }

    it { expect(subject.new_record?).to be false }
  end
end
