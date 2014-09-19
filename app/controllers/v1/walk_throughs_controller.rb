class V1::WalkThroughsController < ApplicationController
  before_action :authenticate_user!

  def viewed
    container = find_container(params[:walk_through_id])

    WalkThrough::View.create!(user: current_user, container: container) 
    render nothing: true
  end

  def show
    @container = find_container(params[:id])
  end

  private
  def find_container(id)
    WalkThrough::Container.find(id)
  end
end
