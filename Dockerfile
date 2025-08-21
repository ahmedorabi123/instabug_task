# # syntax=docker/dockerfile:1
# # check=error=true

# # # # This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# # # # docker build -t store .
# # # # docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name store store

# # # # For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# # # # Make sure RUBY_VERSION matches the Ruby version in .ruby-version
# # # ARG RUBY_VERSION=3.2.2
# # # FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# # # # Rails app lives here
# # # WORKDIR /rails

# # # # Install base packages
# # # RUN apt-get update -qq && \
# # #     apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
# # #     rm -rf /var/lib/apt/lists /var/cache/apt/archives

# # # # Set production environment
# # # ENV RAILS_ENV="production" \
# # #     BUNDLE_DEPLOYMENT="1" \
# # #     BUNDLE_PATH="/usr/local/bundle" \
# # #     BUNDLE_WITHOUT="development"

# # # # Throw-away build stage to reduce size of final image
# # # FROM base AS build

# # # # Install packages needed to build gems
# # # RUN apt-get update -qq && \
# # #     apt-get install --no-install-recommends -y build-essential git libyaml-dev pkg-config && \
# # #     rm -rf /var/lib/apt/lists /var/cache/apt/archives

# # # # Install application gems
# # # COPY Gemfile Gemfile.lock ./
# # # RUN bundle install && \
# # #     rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
# # #     bundle exec bootsnap precompile --gemfile

# # # # Copy application code
# # # COPY . .

# # # # Precompile bootsnap code for faster boot times
# # # RUN bundle exec bootsnap precompile app/ lib/

# # # # Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# # # RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile




# # # # Final stage for app image
# # # FROM base

# # # # Copy built artifacts: gems, application
# # # COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
# # # COPY --from=build /rails /rails

# # # # Run and own only the runtime files as a non-root user for security
# # # RUN groupadd --system --gid 1000 rails && \
# # #     useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
# # #     chown -R rails:rails db log storage tmp
# # # USER 1000:1000

# # # # Entrypoint prepares the database.
# # # ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# # # # Start server via Thruster by default, this can be overwritten at runtime
# # # EXPOSE 80
# # # CMD ["./bin/thrust", "./bin/rails", "server"]
# # # syntax=docker/dockerfile:1


# ARG RUBY_VERSION=3.2.2
# FROM ruby:$RUBY_VERSION-slim AS base

# WORKDIR /rails

# # Add entrypoint script
# COPY entrypoint.sh /usr/bin/entrypoint.sh
# RUN chmod +x /usr/bin/entrypoint.sh

# # Set as container entrypoint
# ENTRYPOINT ["/usr/bin/entrypoint.sh"]


# # Install OS dependencies for Rails + native debugging gems
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y \
#     curl build-essential git libpq-dev libvips \
#     libyaml-dev pkg-config nodejs yarn sqlite3 \
#     ruby-dev libssl-dev libreadline-dev zlib1g-dev && \
#     rm -rf /var/lib/apt/lists/*

# # Set environment for development (not production)
# ENV RAILS_ENV=development \
#     BUNDLE_DEPLOYMENT=0 \
#     BUNDLE_PATH=/usr/local/bundle

# # Install Gems (including development/test group for debug)
# COPY Gemfile Gemfile.lock ./
# RUN bundle install --jobs 4 --retry 3

# # Copy application code
# COPY . .

# # (Optional) Precompile assets (for production only)
# # RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# # Expose Rails dev portsss
# EXPOSE 3000

# # Run Rails in dev mode with binding to all interfaces
# CMD ["./bin/rails", "server", "-b", "0.0.0.0"]




# ARG RUBY_VERSION=3.2.2
# FROM ruby:$RUBY_VERSION-slim AS base

# WORKDIR /rails

# # Install OS dependencies for Rails
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y \
#     curl build-essential git libpq-dev libvips \
#     libyaml-dev pkg-config nodejs yarn sqlite3 \
#     ruby-dev libssl-dev libreadline-dev zlib1g-dev && \
#     rm -rf /var/lib/apt/lists/*

# # Install bundler matching the version in your Gemfile.lock (or latest)
# RUN gem install bundler

# # Copy entrypoint
# COPY entrypoint.sh /usr/bin/entrypoint.sh
# RUN chmod +x /usr/bin/entrypoint.sh
# ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# # Copy Gem files and install gems
# COPY Gemfile ./
# RUN bundle install --jobs 4 --retry 3

# # Copy application code
# COPY . .

# EXPOSE 3000
# CMD ["./bin/rails", "server", "-b", "0.0.0.0"]

# FROM ruby:3.2.2

# # Install required packages
# RUN apt-get update -qq && apt-get install -y nodejs postgresql-client bash

# # Pin Bundler version (change to match your local version if needed)
# ENV BUNDLER_VERSION=2.5.6
# RUN gem install bundler -v "$BUNDLER_VERSION"

# # Set working directory
# WORKDIR /rails

# # Copy Gemfile first for caching
# COPY Gemfile Gemfile.lock ./
# RUN bundle install

# # Copy application code
# COPY . .

# # Ensure entrypoint script uses LF and is executable
# RUN sed -i 's/\r$//' entrypoint.sh && chmod +x entrypoint.sh

# ENTRYPOINT ["./entrypoint.sh"]

# # Default command
# CMD ["rails", "server", "-b", "0.0.0.0"]






ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Add entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Set as container entrypoint
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Install OS dependencies for Rails + native debugging gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl build-essential git libpq-dev libvips \
    libyaml-dev pkg-config nodejs yarn sqlite3 \
    ruby-dev libssl-dev libreadline-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Install the specific Bundler version before bundle install
# RUN gem install bundler -v 2.4.19

# Set environment for development (not production)
ENV RAILS_ENV=development \
    BUNDLE_DEPLOYMENT=0 \
    BUNDLE_PATH=/usr/local/bundle

# Install Gems (including development/test group for debug)
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.4.19
RUN bundle _2.4.19_ install --jobs 4 --retry 3

# Copy application code
COPY . .

# (Optional) Precompile assets (for production only)
# RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Expose Rails dev port
EXPOSE 3000
