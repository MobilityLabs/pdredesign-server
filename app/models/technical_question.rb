# == Schema Information
#
# Table name: technical_questions
#
#  id             :integer          not null, primary key
#  platform       :text             is an Array
#  hosting        :text
#  connectivity   :text
#  single_sign_on :text
#  created_at     :datetime
#  updated_at     :datetime
#

class TechnicalQuestion < ActiveRecord::Base

  enum platform: {
      browser: 'Browser Based',
      iphone: 'Native iPhone App',
      ipad: 'Native iPad App',
      android_smartphone: 'Native Android Smartphone App',
      android_tablet: 'Native Android Tablet App',
      mac: 'Native Mac App',
      windows: 'Native Windows App',
      surface: 'Native Surface App',
      kindle: 'Native Kindle App',
      custom: 'Custom Hardware',
      other: 'Other'
  }

  enum hosting: {
    onsite: 'Onsite',
    offsite: 'Offsite'
  }

  enum single_sign_on: {
      yes: 'Yes',
      no: 'No'
  }

end
