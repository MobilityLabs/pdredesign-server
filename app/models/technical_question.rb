# == Schema Information
#
# Table name: technical_questions
#
#  id               :integer          not null, primary key
#  platforms        :text             default([]), is an Array
#  hosting          :text
#  connectivity     :integer          default([]), is an Array
#  single_sign_on   :text
#  created_at       :datetime
#  updated_at       :datetime
#  product_entry_id :integer
#

class TechnicalQuestion < ActiveRecord::Base
  belongs_to :product_entry

  acts_as_paranoid

  enum platform_option: {
      browser: 'Browser Based',
      iphone: 'Native iPhone App',
      ipad: 'Native iPad App',
      android_smartphone: 'Native Android Smartphone App',
      android_tablet: 'Native Android Tablet App',
      mac: 'Native Mac App',
      windows: 'Native Windows App',
      surface: 'Native Surface App',
      kindle: 'Native Kindle App',
      custom: 'Custom Hardware'
  }

  enum hosting_option: {
    onsite: 'Onsite',
    offsite: 'Offsite'
  }

  enum single_sign_on_option: {
      yes: 'Yes',
      no: 'No'
  }

  validates :platforms, array_enum: { enum: TechnicalQuestion.platform_options, allow_wildcard: true }
  validates :hosting, inclusion: { in: TechnicalQuestion.hosting_options.values, message: "'%{value}' not permissible" }, allow_blank: true
  validates :single_sign_on, inclusion: { in: TechnicalQuestion.single_sign_on_options.values, message: "'%{value}' not permissible" }, allow_blank: true

end
