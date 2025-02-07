# frozen_string_literal: true

require_relative "clear_search/version"
require "active_record"
require "active_support/concern"
require "rails/railtie"
require_relative "clear_search/railtie"

module ClearSearch
  class Error < StandardError; end

  autoload :Searchable, "clear_search/searchable"
  autoload :Index, "clear_search/models/index"
  autoload :Term, "clear_search/models/term"
  autoload :Occurrence, "clear_search/models/occurrence"
  autoload :Configuration, "clear_search/configuration"
  autoload :Search, "clear_search/search"

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end

# Removed the direct ActiveSupport.on_load call as it's now handled by the Railtie
