# frozen_string_literal: true

module ClearSearch
  class Index < ActiveRecord::Base
    self.table_name = "clear_search_indices"

    has_many :terms, class_name: "ClearSearch::Term", dependent: :destroy
    has_many :occurrences, class_name: "ClearSearch::Occurrence", dependent: :destroy

    validates :record_type, :field, presence: true

    class << self
      def update_for(record, field, content, options)
        index = find_or_create_by!(
          record_type: record.class.name,
          field: field.to_s
        )

        index.update_terms(record, content, options)
      end
    end

    def update_terms(record, content, options)
      return if content.blank?

      transaction do
        # Clear existing occurrences for this record
        occurrences.where(record_id: record.id, record_type: record.class.name).destroy_all

        options[:analyzers].each do |analyzer|
          terms_for_analyzer(content, analyzer).reject(&:blank?).each do |term_text|
            term = terms.find_or_create_by!(text: term_text, analyzer: analyzer.to_s)
            term.occurrences.create!(
              record: record,
              index: self,
              position: 0 # For future positional search support
            )
          end
        end
      end
    end

    private

    def terms_for_analyzer(content, analyzer)
      case analyzer
      when :text
        content.to_s.downcase.split(/\W+/)
      when :prefix
        words = content.to_s.downcase.split(/\W+/)
        words.flat_map { |word| (1..word.length).map { |i| word[0...i] } }
      when :exact
        [content.to_s.downcase]
      else # standard
        content.to_s.downcase.split(/\W+/)
      end
    end
  end
end
