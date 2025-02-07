# ClearSearch

ClearSearch is a powerful and flexible search engine for Ruby on Rails applications that supports multiple databases (SQLite, PostgreSQL, and MySQL).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clear_search'
```

And then execute:

```bash
$ bundle install
```

Generate and run the migrations:

```bash
$ rails generate clear_search:install
$ rails db:migrate
```

## Usage

### Basic Setup

Add the `searchable` block to your model and specify which attributes you want to index:

```ruby
class Post < ApplicationRecord
  belongs_to :account

  searchable do
    index :title
    index :content, with: %i[text prefix exact]
  end
end
```

The `with` option specifies which analyzers to use for the field. Available analyzers are:

- `:standard` (default) - Splits text into words
- `:text` - Similar to standard but optimized for full-text search
- `:prefix` - Enables prefix matching (e.g., "ann" matches "announcement")
- `:exact` - Exact string matching

### Searching

#### Basic Search

Search through all indexed fields:

```ruby
Post.search "announcement"
```

#### Exact Search

Use `%s{"term"}` syntax for exact matching:

```ruby
Post.search %s{"announcement"}
```

#### Field-Specific Search

Search specific fields:

```ruby
Post.search title: "announcement", content: "solid search"
```

You can also use exact matching for specific fields:

```ruby
Post.search title: %s{"announcement"}
```

### Chaining

Search results are ActiveRecord relations, so you can chain them with other scopes:

```ruby
Post.search("announcement").where(published: true).order(created_at: :desc)
```

### Indexing

Records are automatically indexed when they are created or updated. However, if you need to reindex existing records, you can use:

```ruby
# Reindex a single record
post.reindex_search

# Reindex all records for a model
Post.reindex_all
```

This is particularly useful when:

- Adding search to an existing model with data
- Modifying the search configuration
- Recovering from any indexing issues

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/afomera/clear_search.

## License

The gem is available as open source under the terms of the MIT License.
