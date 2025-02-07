# frozen_string_literal: true

module ClearSearch
  class Term < ActiveRecord::Base
    self.table_name = "clear_search_terms"

    belongs_to :index, class_name: "ClearSearch::Index"
    has_many :occurrences, class_name: "ClearSearch::Occurrence", dependent: :destroy

    validates :text, :analyzer, presence: true
    validates :text, presence: true
    validates :text, uniqueness: { scope: [:index_id, :analyzer] }, if: -> { text.present? }

    scope :matching, ->(query) {
      normalized_query = query.to_s.downcase
      where(text: normalized_query)
    }

    scope :prefix_matching, ->(query) {
      normalized_query = query.to_s.downcase
      where("text LIKE ?", "#{normalized_query}%")
    }

    def self.search(query, analyzer: :standard)
      case analyzer
      when :prefix
        prefix_matching(query)
      else
        matching(query)
      end
    end
  end
end
