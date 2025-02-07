# frozen_string_literal: true

module ClearSearch
  class Search
    attr_reader :model_class, :query, :conditions

    def initialize(model_class, query)
      @model_class = model_class
      parse_query(query)
    end

    def results
      return model_class.none if query.blank? && conditions.empty?

      terms_relation = build_terms_relation
      occurrences = Occurrence.search_results(terms_relation)
                             .for_record_type(model_class.name)

      model_class.where(id: occurrences.select(:record_id))
    end

    private

    def parse_query(input)
      case input
      when String
        if input.start_with?('%s{') && input.end_with?('}')
          # Exact search with %s{"term"}
          @query = input[3..-2].tr('"', '') # Remove %s{" and "}
          @analyzer = :exact
        else
          @query = input
          @analyzer = :standard
        end
        @conditions = {}
      when Hash
        @query = nil
        @conditions = input.transform_values do |value|
          if value.is_a?(String) && value.start_with?('%s{') && value.end_with?('}')
            { text: value[3..-2].tr('"', ''), analyzer: :exact }
          else
            { text: value, analyzer: :standard }
          end
        end
      else
        @query = nil
        @conditions = {}
      end
    end

    def build_terms_relation
      if query.present?
        build_global_search_terms
      else
        build_field_specific_terms
      end
    end

    def build_global_search_terms
      indices = Index.where(record_type: model_class.name)
      Term.where(index: indices).search(query, analyzer: @analyzer)
    end

    def build_field_specific_terms
      return Term.none if conditions.empty?

      terms = conditions.map do |field, condition|
        index = Index.find_by(record_type: model_class.name, field: field)
        next Term.none unless index

        Term.where(index: index).search(condition[:text], analyzer: condition[:analyzer])
      end

      terms.reduce(:or)
    end
  end
end
