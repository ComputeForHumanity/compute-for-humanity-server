require File.expand_path("../boot", __FILE__)

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require "dwolla"

# Require code in the lib directory.
Dir["./lib/*.rb"].each { |f| require f }

module ComputeForHumanity
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
  end
end
