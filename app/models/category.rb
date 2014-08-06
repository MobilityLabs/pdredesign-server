# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  axis_id    :integer
#

class Category < ActiveRecord::Base
  belongs_to :axis
  has_many :questions
  has_and_belongs_to_many :organizations

	def rubric_questions(rubric)
    Question
      .includes(:rubrics)
      .where(category: self, rubrics: { id: rubric.id })
  end
end
