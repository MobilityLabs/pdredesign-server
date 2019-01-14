# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default("")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  role                   :string(255)
#  team_role              :string(255)
#  admin                  :boolean          default(FALSE)
#  first_name             :string(255)
#  last_name              :string(255)
#  twitter                :string(255)
#  avatar                 :string(255)
#  ga_dimension           :string(255)
#

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :masqueradable

  include Authority::UserAbilities
  has_many :assessments, through: :participants
  has_many :participants
  has_many :feedbacks
  has_many :tools
  has_many :inventories, foreign_key: 'owner_id'

  has_and_belongs_to_many :organizations
  has_and_belongs_to_many :districts

  validates :first_name, presence: true
  validates :last_name, presence: true

  before_save :queue_avatar_updater, if: :twitter_changed?
  def queue_avatar_updater
    TwitterAvatarWorker.perform_async(id)
  end

  def avatar
    self[:avatar] || ActionController::Base.helpers.asset_path('default')
  end

  def role
    return :network_partner if network_partner?
    :district_member
  end

  def district_member?
    !network_partner?
  end

  def network_partner?
    (self[:role] && self[:role].to_s) == 'network_partner'
  end

  def email=(value)
    self[:email] = value.downcase
  end

  def name
    "#{first_name} #{last_name}"
  end

  def ensure_district(district:)
    return if districts.include? district
    districts << district
  end

  def inventories
    Inventory.
        distinct.
        joins('LEFT OUTER JOIN inventory_members ON inventory_members.inventory_id = inventories.id').
        where('inventory_members.user_id = ?', self.id)
  end
end
