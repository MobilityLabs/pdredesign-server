class CurrentLevelAuthorizer < ApplicationAuthorizer
  def readable_by?(user)
    true
  end

  def updatable_by?(user)
    owner?(user) || facilitator?(user)
  end

end