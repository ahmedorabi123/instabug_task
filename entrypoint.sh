#!/bin/bash
set -e

# Remove pre-existing server.pid for Rails
rm -f /rails/tmp/pids/server.pid

# Load environment variables from .env if present
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "⚠️  .env file not found. Please create one (you can start from .env.example)."
fi

# Prepare database (create + migrate)
bundle exec rails db:prepare

# Execute the container's main command
exec "$@"
