# frozen_string_literal: true

module ClearSearch
  class Occurrence < ActiveRecord::Base
    self.table_name = "clear_search_occurrences"

    belongs_to :term, class_name: "ClearSearch::Term"
    belongs_to :index, class_name: "ClearSearch::Index"
    belongs_to :record, polymorphic: true

    validates :term_id, :index_id, :record_id, :record_type, presence: true
    validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    # Ensure uniqueness of term occurrences per record and field
    validates :term_id, uniqueness: { scope: [:record_id, :record_type, :index_id] }

    scope :for_record_type, ->(type) { where(record_type: type.to_s) }
    
    def self.search_results(terms_relation)
      base_query = joins(:term)
        .where(term: terms_relation)
        .for_record_type(terms_relation.first&.index&.record_type)

      case connection.adapter_name.downcase
      when 'postgresql'
        subquery = base_query
          .select("#{table_name}.record_id")
          .select("ROW_NUMBER() OVER (PARTITION BY #{table_name}.record_id ORDER BY #{table_name}.position) as row_num")
        
        from("(#{subquery.to_sql}) AS #{table_name}")
          .where("row_num = 1")
          .select(:record_id)
      when 'mysql', 'mysql2'
        subquery = base_query
          .select("#{table_name}.record_id")
          .select("ROW_NUMBER() OVER (PARTITION BY #{table_name}.record_id ORDER BY #{table_name}.position) as row_num")
        
        from("(#{subquery.to_sql}) AS #{table_name}")
          .where("row_num = 1")
          .select(:record_id)
      else
        # Fallback to GROUP BY for SQLite and other databases
        base_query
          .group(:record_id)
          .select(:record_id)
          .order("#{table_name}.position")
      end
    end
  end
end
