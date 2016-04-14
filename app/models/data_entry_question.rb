# == Schema Information
#
# Table name: data_entry_questions
#
#  id                   :integer          not null, primary key
#  who_enters_data      :text
#  how_data_is_entered  :text
#  when_data_is_entered :text
#  created_at           :datetime
#  updated_at           :datetime
#  data_entry_id        :integer
#

class DataEntryQuestion < ActiveRecord::Base

  belongs_to :data_entry

  enum data_entered_frequency: {
      yearly: 'Yearly',
      quarterly: 'Quarterly',
      monthly: 'Monthly',
      weekly: 'Weekly',
      daily: 'Daily',
      scheduled: 'Scheduled'
  }

  validates :when_data_is_entered, array_enum: {enum: DataEntryQuestion.data_entered_frequencies, flat: true}

end
