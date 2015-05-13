source "https://rubygems.org"

ruby ENV["RUBY_VERSION"] || "2.2.0"

gem "attr_encrypted", "~> 1.3"
gem "coinbase", github: "coinbase/coinbase-ruby"
gem "dwolla-ruby", "~> 2.6"
gem "memoist", "~> 0.12"
gem "money-rails", "~> 1.4"
gem "pg", "~> 0.18"
gem "rails", "4.2.1"
gem "rollbar", "~> 1.5"
gem "sass-rails", "~> 5.0"
gem "turbolinks", "~> 2.5"
gem "uglifier", ">= 1.3.0"

group :production do
  gem "connection_pool", "~> 2.2"
  gem "dalli", "~> 2.7"
  gem "puma", "~> 2.11"
  gem "rails_12factor", "~> 0.0"
end

group :development, :test do
  gem "byebug"
  gem "spring"
  gem "web-console", "~> 2.0"
end
