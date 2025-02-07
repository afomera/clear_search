# frozen_string_literal: true

module ClearSearch
  class Railtie < Rails::Railtie
    initializer "clear_search.extend_active_record" do
      ActiveSupport.on_load(:active_record) do
        include ClearSearch::Searchable
      end
    end
  end
end
