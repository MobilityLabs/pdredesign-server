# == Schema Information
#
# Table name: data_entries
#
#  id                       :integer          not null, primary key
#  general_data_question_id :integer          not null
#  data_entry_question_id   :integer          not null
#  data_access_question_id  :integer          not null
#  created_at               :datetime
#  updated_at               :datetime
#

class DataEntry < ActiveRecord::Base

  has_one :general_data_question, dependent: :delete
  has_one :data_entry_question, dependent: :delete
  has_one :data_access_question, dependent: :delete

  belongs_to :inventory

  validates :general_data_question, presence: true

  delegate :subcategory, :point_of_contact_name, :point_of_contact_department, :data_capture, to: :general_data_question, prefix: false
  delegate :who_enters_data, :how_data_is_entered, :when_data_is_entered, to: :data_entry_question, prefix: false, allow_nil: true
  delegate :data_storage, :who_access_data, :how_data_is_accessed, :why_data_is_accessed, :notes, to: :data_access_question, prefix: false, allow_nil: true



  accepts_nested_attributes_for :general_data_question
  accepts_nested_attributes_for :data_entry_question
  accepts_nested_attributes_for :data_access_question

  default_scope {
    includes(:general_data_question, :data_entry_question, :data_access_question)
  }
end
