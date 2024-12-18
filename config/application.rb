require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LogManagerApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Tokyo"
    config.i18n.default_locale = :ja

    config.action_cable.mount_path = nil
    config.active_storage.service = :null
    config.active_job.queue_adapter = :async
    config.action_mailbox.ingress = :disabled
    config.action_mailer.perform_deliveries = false
    config.action_mailer.delivery_method = :test

    config.assets.compile = true

    # config.eager_load_paths << Rails.root.join("extras")
  end
end
