source "https://rubygems.org"

ruby ENV["RUBY_VERSION"] || "2.2.0"

gem "attr_encrypted", "~> 1.3"
gem "connection_pool", "~> 2.2"
gem "dwolla-ruby", "~> 2.6"
gem "memoist", "~> 0.12"
gem "money-rails", "~> 1.4"
gem "newrelic_rpm", "~> 3.12"
gem "pg", "~> 0.18"
gem "puma", "~> 2.11"
gem "rails", "~> 4.2.5"
gem "redis", "~> 3.2"
gem "rollbar", "~> 1.5"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"

group :production do
  gem "rails_12factor", "~> 0.0"
end

group :development, :test do
  # Overcommit and friends.
  gem "brakeman", require: false
  gem "overcommit", require: false
  gem "rubocop", require: false
  gem "scss_lint", require: false

  # Dev dependencies.
  gem "byebug", require: false
  gem "derailed", require: false
  gem "flamegraph"
  gem "rack-mini-profiler"
  gem "spring"
  gem "stackprof"
  gem "web-console", "~> 2.0"
end
