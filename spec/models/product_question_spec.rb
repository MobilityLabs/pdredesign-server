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

require 'spec_helper'

describe ProductQuestion do

  it { is_expected.not_to allow_value(['foo']).for(:how_its_assigned) }
  it { is_expected.not_to allow_value(['foo']).for(:how_its_used) }
  it { is_expected.not_to allow_value(['foo']).for(:how_its_accessed) }
  it { is_expected.not_to allow_value(['foo']).for(:audience) }

  it { is_expected.to allow_value(ProductQuestion.assignment_approaches.values).for(:how_its_assigned) }
  it { is_expected.to allow_value(ProductQuestion.usage_frequencies.values).for(:how_its_used) }
  it { is_expected.to allow_value(ProductQuestion.accesses.values).for(:how_its_accessed) }
  it { is_expected.to allow_value(ProductQuestion.audience_types.values).for(:audience) }

end