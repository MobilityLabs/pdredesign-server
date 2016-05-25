class V1::AnalysisReportsController < ApplicationController
  before_action :authenticate_user!

  def comparison_data
    @comparison_data = fetch_comparison_data
  end

  def review_header_data
    @categories = fetch_review_header_data
  end

  def fetch_review_body_data(supporting_response_id)
    supporting_inventory_response = SupportingInventoryResponse.where(id: supporting_response_id).first
    if supporting_inventory_response
      GeneralInventoryQuestion
          .where(product_entry_id: supporting_inventory_response.product_entries)
    else
      []
    end
  end

  private
  def fetch_comparison_data
    GeneralInventoryQuestion.find_by_sql ["SELECT
        pe.id,
        giq.product_name,
        giq.price_in_cents,
        uq.usage
      FROM general_inventory_questions giq
        INNER JOIN product_entries pe ON giq.product_entry_id = pe.id
        INNER JOIN usage_questions uq ON uq.product_entry_id = pe.id
      WHERE pe.deleted_at IS NULL AND pe.inventory_id IN (
        SELECT DISTINCT product_entries.inventory_id
        FROM product_entries
          INNER JOIN general_inventory_questions ON general_inventory_questions.product_entry_id = product_entries.id
        WHERE general_inventory_questions.product_entry_id IN (
          SELECT DISTINCT UNNEST(supporting_inventory_responses.product_entries)
          FROM supporting_inventory_responses
          WHERE supporting_inventory_responses.score_id IN (SELECT scores.id
                                                            FROM scores
                                                            WHERE scores.response_id = ?)))",
                                          current_response.id]
  end

  def fetch_review_header_data
    Question.select(:headline,
                    'COALESCE(array_length(product_entries, 1), 0) AS product_count',
                    'supporting_inventory_responses.id AS supporting_response_id')
        .joins('INNER JOIN scores ON scores.question_id = questions.id
                INNER JOIN supporting_inventory_responses ON supporting_inventory_responses.score_id = scores.id')
        .where(scores: {id: current_response.scores})
  end

  def current_analysis
    @analysis ||= Analysis.where(id: params[:analysis_id]).first
  end

  def current_response
    @response ||= Response.where(responder: current_analysis).first
  end

end
