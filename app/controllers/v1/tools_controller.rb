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

  def tools_for(subcategory)
    default_tools(subcategory) + 
    subcategory
      .tools
      .joins(:districts)
      .where(districts: {id: current_user.district_ids})
  end

  private
  def default_tools(subcategory)
    subcategory.tools.where(is_default: true)
  end

  def tool_create_params
    params.permit(:title, :description, :url, :tool_subcategory_id)
  end
end
