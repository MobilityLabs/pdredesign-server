# == Schema Information
#
# Table name: tools
#
#  id                  :integer          not null, primary key
#  title               :string(255)
#  description         :text
#  url                 :string(255)
#  is_default          :boolean
#  display_order       :integer
#  tool_subcategory_id :integer
#  user_id             :integer
#

class Tool < ActiveRecord::Base
  belongs_to :tool_subcategory
  belongs_to :user
  belongs_to :tool_category

  has_one    :tool_category, through: :tool_subcategory
  has_many   :districts, through: :user

  validates :title, presence: true

  scope :the_defaults, -> { where(is_default: true) }
end
