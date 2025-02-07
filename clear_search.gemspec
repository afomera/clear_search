# frozen_string_literal: true

require_relative "lib/clear_search/version"

Gem::Specification.new do |spec|
  spec.name = "clear_search"
  spec.version = ClearSearch::VERSION
  spec.authors = ["Andrea Fomera"]
  spec.email = ["afomera@hey.com"]

  spec.summary = "A powerful search engine for Ruby on Rails applications"
  spec.description = "ClearSearch provides a simple and flexible way to add full-text search capabilities to your Rails models with support for multiple databases."
  spec.homepage = "https://github.com/afomera/clear_search"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/afomera/clear_search"
  spec.metadata["changelog_uri"] = "https://github.com/afomera/clear_search/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
