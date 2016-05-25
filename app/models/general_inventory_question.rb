# == Schema Information
#
# Table name: general_inventory_questions
#
#  id                          :integer          not null, primary key
#  product_name                :text
#  vendor                      :text
#  point_of_contact_name       :text
#  point_of_contact_department :text
#  pricing_structure           :text
#  price_in_cents              :integer
#  data_type                   :text             default([]), is an Array
#  purpose                     :text
#  created_at                  :datetime
#  updated_at                  :datetime
#  product_entry_id            :integer
#

class GeneralInventoryQuestion < ActiveRecord::Base
  belongs_to :product_entry

  acts_as_paranoid

  enum pricing_structure_option: {
    free: 'Free',
    one_time_purchase: 'One Time Purchase',
    license: 'License',
    usage_based: 'Usage Based'
  }

  enum product_type: {
      academic_content: 'PD for Academic Content',
      instructional_skills: 'PD for Instructional Skills',
      pedagogies: 'PD for Pedagogies',
      curriculum_products: 'Curriculum Products',
      teacher_classroom_needs: 'Teacher Classroom Needs',
      human_resources: 'Human Resources'
  }

  validates :product_name, presence: true
  validates :data_type, array_enum: { enum: GeneralInventoryQuestion.product_types }
  validates :price_in_cents, numericality: {only_integer: true, greater_than_or_equal_to: 0}, allow_blank: true
end
