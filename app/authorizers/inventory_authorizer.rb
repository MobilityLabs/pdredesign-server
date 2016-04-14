class InventoryAuthorizer < ApplicationAuthorizer
  def creatable_by?(user)
    true
  end

  def updatable_by?(user)
    resource.facilitator?(user: user)
  end

  def readable_by?(user)
    resource.member?(user: user)
  end

  def deletable_by?(user)
    resource.facilitator?(user: user)
  end
end
