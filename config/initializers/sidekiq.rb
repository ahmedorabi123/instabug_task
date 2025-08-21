require "sidekiq"
require "sidekiq-cron"

# Configure Redis connection using ENV variable
redis_url = ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" }

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  # Load cron jobs from config/schedule.yml if it exists
  schedule_file = Rails.root.join("config", "schedule.yml")
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
