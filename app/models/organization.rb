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

  def self.search(search = '')
    return limit(10) if search.empty?

    limit(10).where('LOWER(name) LIKE ?', "%#{search.downcase}%")
  end

end
