class ResponseAuthorizer < ApplicationAuthorizer
  def creatable_by?(user)
    return false unless resource.responder
    is_facilitator_or_owner(user)
  end

  def updatable_by?(user)
    is_facilitator_or_owner(user)
  end

  def readable_by?(user)
    return false unless resource.responder
    return true  if resource.responder_type == 'Assessment'
    resource.responder.user_id == user.id
  end

  private
  def is_facilitator_or_owner(user)
    if resource.responder && resource.responder_type == "Assessment"
      resource.responder.facilitator?(user)
    else
      resource.responder.user_id == user.id
    end
  end
end

