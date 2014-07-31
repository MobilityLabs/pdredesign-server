# == Schema Information
#
# Table name: organizations
#
#  id   :integer          not null, primary key
#  name :string(255)
#  logo :string(255)
#

class Organization < ActiveRecord::Base
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :users

  mount_uploader :logo, LogoUploader

end
