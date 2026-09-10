require_relative 'boot'

require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"

Bundler.require(*Rails.groups)
require "url_shortner"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Turned on deliberately: with it off the suite could not see that the
    # engine's redirect was broken for every real host app. Rails 8.1 renamed
    # the setting and made :log the default, so ask for :raise by name there
    # and fall back for the 7.0-8.0 range the gemspec still allows.
    if Rails.gem_version >= Gem::Version.new("8.1")
      config.action_controller.action_on_open_redirect = :raise
    else
      config.action_controller.raise_on_open_redirects = true
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

