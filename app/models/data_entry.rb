# == Schema Information
#
# Table name: data_entries
#
#  id           :integer          not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  inventory_id :integer
#  name         :text
#

class DataEntry < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer_name = 'DataEntryAuthorizer'

  # XXX These were (and should be) dependent: :delete
  # but the paranoia gem doesn't work with that for the restoring behaviour
  # https://github.com/rubysherpas/paranoia/issues/320
  has_one :general_data_question, -> { with_deleted }, dependent: :destroy
  has_one :data_entry_question, -> { with_deleted }, dependent: :destroy
  has_one :data_access_question, -> { with_deleted }, dependent: :destroy

  belongs_to :inventory

  acts_as_paranoid

  validates :name, presence: true
  validates :general_data_question, presence: true

  delegate :data_type, :point_of_contact_name, :point_of_contact_department, :data_capture, to: :general_data_question, prefix: false
  delegate :who_enters_data, :how_data_is_entered, :when_data_is_entered, to: :data_entry_question, prefix: false, allow_nil: true
  delegate :data_storage, :who_access_data, :how_data_is_accessed, :why_data_is_accessed, :notes, to: :data_access_question, prefix: false, allow_nil: true



  accepts_nested_attributes_for :general_data_question
  accepts_nested_attributes_for :data_entry_question
  accepts_nested_attributes_for :data_access_question

  default_scope {
    includes(:general_data_question, :data_entry_question, :data_access_question)
  }
end
