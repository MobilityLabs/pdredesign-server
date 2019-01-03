# == Schema Information
#
# Table name: rubrics
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  version    :decimal(, )
#  created_at :datetime
#  updated_at :datetime
#  enabled    :boolean
#  tool_type  :string
#

class Rubric < ActiveRecord::Base
  has_many :responses, dependent: :destroy
  has_many :feedbacks

  has_and_belongs_to_many :questions
  has_many :categories, -> { distinct }, through: :questions

  scope :enabled, -> { where(enabled: true) }
  scope :assessment_driven, -> { where(tool_type: Assessment.to_s) }
  scope :analysis_driven, -> { where(tool_type: Analysis.to_s) }

  # Exposed for testing purposes
  attr_accessor :axis

  def versioned_name
    "#{name} v#{version}"
  end
end
