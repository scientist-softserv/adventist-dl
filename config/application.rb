require_relative 'boot'

require 'rails/all'
require 'i18n/debug' if ENV['I18N_DEBUG']

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
groups = Rails.groups
groups += ['bulkrax'] if ENV['SETTINGS__BULKRAX__ENABLED'] == 'true' # Settings obj is not available yet
Bundler.require(*groups)

module Hyku
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Gzip all responses.  We probably could do this in an upstream proxy, but
    # configuring Nginx on Elastic Beanstalk is a pain.
    config.middleware.use Rack::Deflater

    # The locale is set by a query parameter, so if it's not found render 404
    config.action_dispatch.rescue_responses.merge!(
      "I18n::InvalidLocale" => :not_found
    )

    if defined? ActiveElasticJob
      Rails.application.configure do
        config.active_elastic_job.process_jobs = Settings.worker == 'true'
        config.active_elastic_job.aws_credentials = lambda { Aws::InstanceProfileCredentials.new }
        config.active_elastic_job.secret_key_base = Rails.application.secrets[:secret_key_base]
      end
    end

    config.to_prepare do
      # Do dependency injection after the classes have been loaded.
      # Before moving this here (from an initializer) Devise was raising invalid
      # authenticity token errors.
      Hyrax::Admin::AppearancesController.form_class = AppearanceForm

      # See https://gitlab.com/notch8/adventist-dl/-/issues/147
      #
      # By default plain text files are not processed for text extraction.  In adding
      # Adventist::TextFileTextExtractionService to the beginning of the services array we are
      # enabling text extraction from plain text files.
      Hyrax::DerivativeService.services.unshift(Adventist::TextFileTextExtractionService)

      # Allows us to use decorator files
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")).sort.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      Dir.glob(File.join(File.dirname(__FILE__), "../lib/**/*_decorator*.rb")).sort.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # OAI additions
      Dir.glob(File.join(File.dirname(__FILE__), "../lib/oai/**/*.rb")).sort.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

    end

    # resolve reloading issue in dev mode
    config.paths.add 'app/helpers', eager_load: true

    config.before_initialize do
      if defined? ActiveElasticJob
        Rails.application.configure do
          config.active_elastic_job.process_jobs = Settings.worker == 'true'
          config.active_elastic_job.aws_credentials = lambda { Aws::InstanceProfileCredentials.new }
          config.active_elastic_job.secret_key_base = Rails.application.secrets[:secret_key_base]
        end
      end

      Object.include(AccountSwitch)

      if Settings.bulkrax.enabled
        Bundler.require('bulkrax')
      end
    end
  end
end
