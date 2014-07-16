class V1::ToolsController < ApplicationController
  def index
    @phases = ToolPhase.all
  end

  def create
    @tool      = Tool.new(tool_create_params)
    @tool.user = current_user

    if @tool.save
      render :show
    else
      @errors = @tool.errors
      render 'v1/shared/errors', status: 422
    end
  end

  private
  def tool_create_params
    params.permit(:title, :description, :url, :tool_category_id, :district_id)
  end
end
