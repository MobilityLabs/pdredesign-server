class ShareTokenAssessments < ActiveRecord::Migration
  def up
    Assessment.all.each do |assessment|
      assessment.ensure_share_token
      assessment.save!
    end
  end

  def down
    Assessment.all.each do |assessment|
      assessment.update_columns(share_token: nil)
    end
  end
end
