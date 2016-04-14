# == Schema Information
#
# Table name: product_questions
#
#  id               :integer          not null, primary key
#  how_its_assigned :text             default([]), is an Array
#  how_its_used     :text             default([]), is an Array
#  how_its_accessed :text             default([]), is an Array
#  audience         :text             default([]), is an Array
#  created_at       :datetime
#  updated_at       :datetime
#  product_entry_id :integer
#

class ProductQuestion < ActiveRecord::Base

  belongs_to :product_entry

  enum assignment_approach: {
      teacher_choice: 'Teacher Choice',
      data_driven: 'Data Driven',
      differentiated: 'Differentiated',
      adaptive: 'Adaptive'
  }

  enum usage_frequency: {
      anytime_anywhere: 'Anytime Anywhere',
      blended: 'Blended',
      scheduled: 'Scheduled'
  }

  enum access: {
      content_repository: 'Content Repository',
      video_share: 'Video Share Platform',
      social_network: 'Social Network',
      video_library: 'Video Library',
      webinars: 'Webinars',
      asynchronous_modules: 'Asynchronous Modules',
      online_courses: 'Online Courses'
  }

  enum audience_type: {
      admin_audience: 'Administrators',
      teacher_audience: 'Teachers',
      home_school_audience: 'Home School',
      parent_audience: 'Parents',
      student_audience: 'Students'
  }

  validates :how_its_assigned, array_enum: {enum: ProductQuestion.assignment_approaches}
  validates :how_its_used, array_enum: {enum: ProductQuestion.usage_frequencies}
  validates :how_its_accessed, array_enum: {enum: ProductQuestion.accesses}
  validates :audience, array_enum: {enum: ProductQuestion.audience_types}

end
