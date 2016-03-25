# == Schema Information
#
# Table name: access_requests
#
#  id            :integer          not null, primary key
#  assessment_id :integer
#  user_id       :integer
#  roles         :string           default([]), is an Array
#  created_at    :datetime
#  updated_at    :datetime
#  token         :string(255)
#

class AccessRequest < ActiveRecord::Base
  belongs_to :assessment
  belongs_to :user

  validates :roles, presence: true
  validates :user_id, presence: true
  validates :assessment_id, presence: true

  before_destroy  :flush_assessment_cached_version
  after_create    :flush_assessment_cached_version

  def flush_assessment_cached_version
    self.assessment.flush_cached_version
  end
end
