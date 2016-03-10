# == Schema Information
#
# Table name: inventories
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  deadline    :datetime         not null
#  district_id :integer          not null
#

class Inventory < ActiveRecord::Base
  has_many :product_entries
  has_many :data_entries
  belongs_to :district

  accepts_nested_attributes_for :product_entries
  accepts_nested_attributes_for :data_entries
end
