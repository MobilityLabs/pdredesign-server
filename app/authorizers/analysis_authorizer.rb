class AnalysisAuthorizer < ApplicationAuthorizer
  def readable_by?(user)
    fetch_inventory_permissions(user)
  end

  def creatable_by?(user)
    fetch_inventory_permissions(user)
  end

  def updatable_by?(user)
    fetch_inventory_permissions(user)
  end

  def deletable_by?(user)
    fetch_inventory_permissions(user)
  end

  private
  def fetch_inventory_permissions(user)
    is_owner_of_inventory?(user) || is_facilitator_of_inventory?(user) || is_participant_of_inventory?(user)
  end

  def is_facilitator_of_inventory?(user)
    resource.inventory.try(:facilitator?, user: user)
  end

  def is_participant_of_inventory?(user)
    resource.inventory.try(:participant?, user: user)
  end

  def is_owner_of_inventory?(user)
    resource.inventory.try(:owner?, user: user)
  end
end
