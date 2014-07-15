class V1::ToolkitsController < ApplicationController
  def index

    arel = ToolPhase.includes(:tool_categories)

    arel = arel.includes(tool_categories: :tool_subcategories)

    arel = arel.includes(tool_categories: :tools).where(tools: {is_default: true})

    render json: arel.to_json(:include => { :tool_categories =>
                                            { :include => { :tool_subcategories =>
                                              { :include => :tools}
                                               }
                                            }
                                          }
                             )
  end
end
