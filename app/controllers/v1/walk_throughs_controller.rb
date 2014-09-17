class V1::WalkThroughsController < ApplicationController
  def show
    @container = WalkThrough::Container.find(params[:id])
  end
end


