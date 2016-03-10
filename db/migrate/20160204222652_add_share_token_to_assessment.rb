class AddShareTokenToAssessment < ActiveRecord::Migration
  def change
    add_column :assessments, :share_token, :string
  end
end
