# == Schema Information
#
# Table name: product_entries
#
#  id                            :integer          not null, primary key
#  general_inventory_question_id :integer          not null
#  product_question_id           :integer
#  usage_question_id             :integer          not null
#  technical_question_id         :integer          not null
#  created_at                    :datetime
#  updated_at                    :datetime
#

class ProductEntry < ActiveRecord::Base

  has_one :general_inventory_question, dependent: :delete
  has_one :product_question, dependent: :delete
  has_one :usage_question, dependent: :delete
  has_one :technical_question, dependent: :delete

  belongs_to :inventory

  validates :general_inventory_question, presence: true
  validates :usage_question, presence: true
  validates :technical_question, presence: true

  delegate :product_name, :vendor, :point_of_contact_name, :point_of_contact_department, :pricing_structure, :price, :data_type, :purpose,
           to: :general_inventory_question, prefix: false
  delegate :how_its_assigned, :how_its_used, :how_its_accessed, :audience, to: :product_question, prefix: false, allow_nil: true
  delegate :school_usage, :usage, :vendor_data, :notes, to: :usage_question, prefix: false
  delegate :platform, :hosting, :connectivity, :single_sign_on, to: :technical_question, prefix: false

  accepts_nested_attributes_for :general_inventory_question
  accepts_nested_attributes_for :product_question
  accepts_nested_attributes_for :usage_question
  accepts_nested_attributes_for :technical_question


  default_scope {
    includes(:general_inventory_question, :product_question, :usage_question, :technical_question)
  }
end
