# == Schema Information
#
# Table name: organizations
#
#  id   :integer          not null, primary key
#  name :string(255)
#  logo :string(255)
#

class Organization < ActiveRecord::Base
  include Authority::Abilities
  
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: true

  mount_uploader :logo, LogoUploader

  include SimpleSearch
end
