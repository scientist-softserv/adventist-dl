require_relative 'boot'

require 'rails/all'
require 'i18n/debug' if ENV['I18N_DEBUG']

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
groups = Rails.groups
Bundler.require(*groups)

module Hyku
  # Providing a common method to ensure consistent UTF-8 encoding.  Also removing the tricksy Byte
  # Order Marker character which is an invisible 0 space character.
  #
  # @note In testing, we encountered errors with the file's character encoding
  #       (e.g. `Encoding::UndefinedConversionError`).  The following will force the encoding to
  #       UTF-8 and replace any invalid or undefined characters from the original encoding with a
  #       "?".
  #
  #       Given that we still have the original, and this is a derivative, the forced encoding
  #       should be acceptable.
  #
  # @param [String]
  # @return [String]
  #
  # @see https://sentry.io/organizations/scientist-inc/issues/3773392603/?project=6745020&query=is%3Aunresolved&referrer=issue-stream
  # @see https://github.com/samvera-labs/bulkrax/pull/689
  # @see https://github.com/samvera-labs/bulkrax/issues/688
  # @see https://github.com/scientist-softserv/adventist-dl/issues/179
  def self.utf_8_encode(string)
    string
      .encode(Encoding.find('UTF-8'), invalid: :replace, undef: :replace, replace: "?")
      .delete("\xEF\xBB\xBF")
  end

  class Application < Rails::Application
    # Add this line to load the lib folder first because we need
    # IiifPrint::SplitPdfs::AdventistPagesToJpgsSplitter
    config.autoload_paths.unshift("#{Rails.root}/lib")

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

      # By default plain text files are not processed for text extraction.  In adding
      # Adventist::TextFileTextExtractionService to the beginning of the services array we are
      # enabling text extraction from plain text files.
      # Hyrax::DerivativeService.services = [
      #   Adventist::TextFileTextExtractionService,
      #   IiifPrint::PluggableDerivativeService]

      # When you are ready to use the derivative rodeo instead of the pluggable uncomment the
      # following and comment out the preceding Hyrax::DerivativeService.service
      #
      Hyrax::DerivativeService.services = [
        Adventist::TextFileTextExtractionService,
        IiifPrint::DerivativeRodeoService,
        Hyrax::FileSetDerivativesService]

      DerivativeRodeo::Generators::HocrGenerator.additional_tessearct_options = "-l eng_best"

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

      # See: https://github.com/scientist-softserv/adventist-dl/issues/676
      IiifPrint::DerivativeRodeoService.named_derivatives_and_generators_filter =
        ->(file_set:, filename:, named_derivatives_and_generators:) do
          named_derivatives_and_generators.reject do |named_derivative, generators|
            named_derivative != :thumbnail && filename.downcase.ends_with?(Hyku::THUMBNAIL_FILE_SUFFIX)
          end
        end
    end

    # resolve reloading issue in dev mode
    config.paths.add 'app/helpers', eager_load: true
    config.active_record.yaml_column_permitted_classes = [OpenStruct, Symbol, Time, URI, BigDecimal, Date, DateTime, ActiveSupport::TimeWithZone, ActiveSupport::Duration, ActiveSupport::TimeZone, ActiveSupport::HashWithIndifferentAccess, ActiveSupport::OrderedHash]

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

    # copies tinymce assets directly into public/assets
    config.tinymce.install = :copy
  end

  THUMBNAIL_FILE_SUFFIX = '.tn.jpg'
end
