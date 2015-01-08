class V1::AccessController < ApplicationController
  before_action :authenticate_user!

  def grant
    @record  = find_access_request
    status(404) and return unless @record
    status(401) and return unless allowed?(@record)

    grant_access(@record)
    render nothing: true
  end

  private
  def grant_access(record)
    assessment = record.assessment
    record.roles.each do |role|
      send("grant_#{role}", assessment, record.user)
    end

    record.destroy
  end

  def grant_facilitator(assessment, user)
    assessment.facilitators << user   
  end

  def grant_viewer(assessment, user)
    assessment.viewers << user   
  end

  def grant_participant(assessment, user)
    Participant.create!(assessment: assessment, user: user, invited_at: Time.now)
  end

  #TODO: extract to authorizer
  def allowed?(record)
    record.assessment.facilitator?(current_user) 
  end

  def find_access_request
    AccessRequest.find_by(token: params[:token])
  end
end
