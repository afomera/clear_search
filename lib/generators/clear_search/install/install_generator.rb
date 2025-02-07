# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module ClearSearch
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def create_migration_file
        migration_template(
          "install_clear_search.rb.erb",
          "db/migrate/install_clear_search.rb",
          migration_version: migration_version
        )
      end

      private

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if needs_version?
      end

      def needs_version?
        Rails::VERSION::MAJOR >= 5
      end
    end
  end
end
