# frozen_string_literal: true

module ClearSearch
  class Configuration
    attr_accessor :default_analyzers

    def initialize
      @default_analyzers = [:standard]
    end
  end
end
