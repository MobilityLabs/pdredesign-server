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

class DataAccessQuestion < ActiveRecord::Base

  belongs_to :data_entry

  acts_as_paranoid

  enum data_accessed_by: {
      team: 'Team',
      central_office: 'Central Office',
      school_district: 'School District',
      public_access: 'Public',
      other: 'Other'
  }

  validates :who_access_data, inclusion: {in: DataAccessQuestion.data_accessed_bies.values, message: "'%{value}' not permissible" }, allow_blank: true
end
