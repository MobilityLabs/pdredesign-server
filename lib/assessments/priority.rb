module Assessments
  class Priority
    attr_reader :assessment

    def initialize(assessment)
      @assessment = assessment
    end

    def categories
      @records ||= query.reverse_merge(query_general).map { |record| create_category_hash(record) }
      @sorted ||= sorted_categories(@records)
    end

    private
    def priority
      @priority ||= ::Priority.find_by(tool: assessment)
    end

    def order
      priority && priority.order
    end

    def sorted_categories(records)
      return records unless order

      ordered_categories(records, order).tap do |new_order|
        append_missing_categories(new_order, records)
      end.compact
    end

    def ordered_categories(records, order)
      [].tap do |new_order|
        order.each do |id|
          new_order.push(records.detect { |r| r[:id] == id })
          records.delete_if { |r| r[:id] == id }
        end
      end
    end

    def append_missing_categories(target, categories)
      categories.each do |record|
        next if target.include?(record)
        target.push(record)
      end
    end

    def create_category_hash(record)
      Hash.new.tap do |category|
        category[:id] = record[0][0]
        category[:name] = record[0][1]
        category[:average] = record[1] || 0
      end
    end

    def query
      assessment
          .rubric
          .categories
          .joins(questions: :scores)
          .where(scores: {response_id: response_ids})
          .distinct
          .group("categories.id", :name)
          .average("scores.value")
    end

    def query_general
      assessment
          .rubric
          .categories
          .joins(questions: :scores)
          .distinct
          .group("categories.id", :name)
          .average(0)
    end

    def response_ids
      if assessment.has_response? && assessment.response_submitted?
        assessment.response.id
      else
        assessment.participant_responses.pluck(:id)
      end
    end

  end
end
