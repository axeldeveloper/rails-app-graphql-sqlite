# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GraphqlTest
  class Application < Rails::Application
    # Carrega todos os log
    # Rails.autoloaders.log!

    Rails.autoloaders.each do |autoloader|
      autoloader.logger =  nil

      # autoloader.logger = Rails.logger
      # custom_logger = Logger.new(STDOUT)
      # custom_logger.level = Logger::DEBUG
      # autoloader.logger = custom_logger
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.active_record.verify_foreign_keys_for_fixtures = false
    config.active_support.cache_format_version = 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true
    config.active_record.schema_format = :ruby
    config.active_job.queue_adapter = :sidekiq
    config.assets.initialize_on_precompile = true

    # Using Session Middlewares

    # This also configures session_options for use below
    # config.session_store :cookie_store, key: '_app_ror_lite_session'
    # Required for all session management (regardless of session_store)
    config.middleware.use ActionDispatch::Cookies

    # config.middleware.use config.session_store, config.session_options

    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end
end
