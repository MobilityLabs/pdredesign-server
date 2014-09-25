module ApplicationHelper
  def scores_for_assessment(assessment, team_role = nil)
    return assessment.scores_for_team_role(team_role) if team_role
    assessment.answered_scores
  end

  def timestamp(date_time)
    return unless date_time
    date_time.to_datetime.strftime("%s")
  rescue
    nil
  end

  def fetch_districts(district_ids)
    District.where(id: district_ids)
  end
end
