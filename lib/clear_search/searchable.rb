# frozen_string_literal: true

module ClearSearch
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def searchable(&block)
        class_eval do
          @search_config ||= SearchConfiguration.new
          @search_config.instance_eval(&block)
        end

        include InstanceMethods
      end

      def search(query)
        Search.new(self, query).results
      end

      def search_config
        @search_config
      end

      def reindex_all
        find_each do |record|
          record.reindex_search
        end
      end
    end

    module InstanceMethods
      extend ActiveSupport::Concern

      included do
        after_commit :update_search_indices, on: [:create, :update]
        after_commit :remove_from_search_indices, on: [:destroy]
      end

      def reindex_search
        update_search_indices
      end

      private

      def remove_from_search_indices
        self.class.search_config.indexed_fields.each do |field, _options|
          indices = Index.where(record_type: self.class.name, field: field)
          Term.where(index: indices).joins(:occurrences)
              .where(occurrences: { record_id: id, record_type: self.class.name })
              .destroy_all
        end
      end

      def update_search_indices
        self.class.search_config.indexed_fields.each do |field, options|
          content = extract_field_content(field)
          Index.update_for(self, field, content, options) if content.present?
        end
      end

      def extract_field_content(field)
        value = send(field)
        return nil if value.nil?
        
        if defined?(ActionText::RichText) && value.is_a?(ActionText::RichText)
          return value.body.to_plain_text if value.body.present?
          return nil
        end
        
        value.to_s
      end
    end

    class SearchConfiguration
      attr_reader :indexed_fields

      def initialize
        @indexed_fields = {}
      end

      def index(field, options = {})
        options[:analyzers] = [:standard] if options[:with].nil?
        options[:analyzers] = Array(options[:with]) if options[:with]
        @indexed_fields[field] = options
      end
    end
  end
end
