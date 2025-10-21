source "https://rubygems.org"

# Core Rails and related components
gem "rails", "~> 8.0.2"
gem "propshaft" # Asset pipeline
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "pg" # PostgreSQL
gem "redis"

# Background jobs & queues
gem "sidekiq"
gem "sidekiq-cron"

# Elasticsearch
gem "elasticsearch-model"
gem "elasticsearch-rails"

# Caching & concurrency adapters
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Optional platform-specific config
gem "tzinfo-data", platforms: %i[windows jruby]

# Performance
gem "bootsnap", require: false

# Deployment
gem "kamal", require: false
gem "thruster", require: false

# Local development
group :development, :test do
  gem "dotenv-rails" # Load .env files
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

# Linting tools
gem "rubocop", "~> 1.81", group: :development
gem "rubocop-rails", "~> 2.32", group: :development
