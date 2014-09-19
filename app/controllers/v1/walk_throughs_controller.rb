class V1::WalkThroughsController < ApplicationController
  before_action :authenticate_user!

  def viewed
    container = find_container(params[:walk_through_id])

    unless existing_record?(current_user, container)
      WalkThrough::View.create!(user: current_user, container: container) 
    end

    render nothing: true
  end

  def show
    @container = find_container(params[:id])
  end

  private
  def existing_record?(user, container)
    WalkThrough::View
      .where(user: user, container: container)
      .present?
  end

  def find_container(id)
    WalkThrough::Container.find(id)
  end
end
