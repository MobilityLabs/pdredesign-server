module V1
  module AnalysisConsensusHelper
    COL_SEP   = ','
    QUOTE_SEP = '"'

    def analysis_consensus_csv(analysis_consensus={})
      scores_and_relevant_data = Analyses::Priority.new(analysis: analysis_consensus.responder).ordered_list
      CSV.generate(col_sep: COL_SEP, quote_char: QUOTE_SEP) do |csv_content|
        csv_content << analysis_consensus_headers

        scores_and_relevant_data.each do |score|
          csv_content << analysis_consensus_mappings.values.map do |method|
            string = if method.is_a?(Proc)
              method.call(score)
            else
              score.send(method)
            end

            # nil and "" and " " should be treated the same way
            string.presence
          end
        end
      end
    end

    private

    def counter
      @counter ||= 0
      @counter = @counter + 1
    end

    def question_skipped?(score)
      score.value.nil? &&
        score.product_count == 0 &&
        score.data_count == 0 &&
        score.product_entry_evidence.nil? &&
        score.data_entry_evidence.nil?
    end

    def analysis_consensus_mappings
      {
        'Priority' => ->(*){ counter },
        'Category' => :headline,
        'Score' => ->(score){ score.value if score.value.try(:>, 0) },
        'Products' => ->(score){ score.product_count unless question_skipped?(score) },
        'Data' => ->(score){ score.data_count unless question_skipped?(score) },
        'Product Notes' => :product_entry_evidence,
        'Data Notes' => :data_entry_evidence,
        'Total Costs Yearly (USD)' => ->(score){ score.total_cost_yearly / 100 }
      }
    end

    def analysis_consensus_headers
      analysis_consensus_mappings.keys.map(&:to_s)
    end
  end
end
