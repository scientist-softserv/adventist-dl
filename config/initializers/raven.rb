Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.current_environment = Rails.env
end