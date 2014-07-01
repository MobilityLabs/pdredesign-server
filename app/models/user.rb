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
#  invitation_token       :string(255)
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  twitter                :string(255)
#  avatar                 :string(255)
#

class User < ActiveRecord::Base
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include Authority::UserAbilities

  has_many :assessments
  has_many :participants
  has_many :rubrics
  has_many :feedbacks
  has_and_belongs_to_many :districts

  attr_accessor :invited_assessment
  has_many :invitations, class_name: self.to_s, as: :invited_by

  validates :first_name, presence: true
  validates :last_name, presence: true

  validate  :has_districts?

  before_save :queue_avatar_updater, if: :twitter_changed?
  def queue_avatar_updater
    TwitterAvatarWorker.perform_async(id)
  end

  def email=(value)
    self[:email] = value.downcase
  end

  def has_districts?
    return if self.admin?
    errors.add :district_ids, "You must select at least one school district." if self.districts.empty?
  end

  def name
    "#{first_name} #{last_name}"
  end
 
end
