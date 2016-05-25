class DataEntryAuthorizer < ApplicationAuthorizer
  def readable_by?(user)
    is_owner_or_member_of_inventory?(user)
  end

  def creatable_by?(user)
    is_owner_or_member_of_inventory?(user)
  end

  def updatable_by?(user)
    is_owner_or_member_of_inventory?(user)
  end

  def deletable_by?(user)
    is_owner_or_member_of_inventory?(user)
  end
  
  def restorable_by?(user)
    resource.inventory.try(:owner?, user: user) ||
        resource.inventory.try(:facilitator?, user: user)
  end
  
  private
  def is_owner_or_member_of_inventory?(user)
    resource.inventory.try(:owner?, user: user) ||
        resource.inventory.try(:participant?, user: user) ||
        resource.inventory.try(:facilitator?, user: user) ||
        resource.inventory.try(:member?, user: user)
  end
end
