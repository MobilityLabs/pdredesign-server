class AssessmentAuthorizer < ApplicationAuthorizer
  def readable_by?(user)
    can_read_assessment?(user)
  end

  def creatable_by?(user)
    true
  end

  def updatable_by?(user)
    owner?(user) || facilitator?(user)
  end

  def deletable_by?(user)
    facilitator?(user) || owner?(user)
  end

  def participants_listable_by?(user)
    share_districts?(user)
  end

  def current_level_by?(user)
    true
  end

  private
  def can_read_assessment?(user)
    participant?(user) || facilitator?(user)     ||
    owner?(user)       || share_districts?(user) ||
    viewer?(user) 
  end

end
