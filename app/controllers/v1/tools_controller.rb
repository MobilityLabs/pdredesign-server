class V1::ToolsController < ApplicationController
  def index

    arel = ToolPhase.includes(:tool_categories)

    arel = arel.includes(tool_categories: :tool_subcategories)

    arel = arel.includes(tool_categories: :tools) #.where(tools: {is_default: true})

    render json: arel.to_json(:include => { :tool_categories =>
                                            { :include => { :tool_subcategories =>
                                              { :include => :tools}
                                               }
                                            }
                                          }
                             )
  end

  def create
    @tool = Tool.new(tool_create_params)

    @tool.user              = current_user

    if @tool.save
      render :show
    else
      @errors = @tool.errors
      render 'v1/shared/errors', status: 422
    end
  end

  private

  def tool_create_params
    params.permit(:title, :description, :url, :tool_category_id)
  end
end
