# frozen_string_literal: true

class RedisEndpoint < Endpoint
  store :options, accessors: [:namespace]

  # Reset the Redis namespace back to the default value
  def self.reset!
    Hyrax.config.redis_namespace = Settings.redis.default_namespace
    # Sidekiq does not set namespace by default
    switch_sidekiq(nil)
  end

  def self.switch_sidekiq(sidekiq_namespace)
    yaml = YAML.safe_load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)
    config = yaml[Rails.env].with_indifferent_access
    redis_config = config.merge(thread_safe: true)
    redis_config = redis_config.merge(namespace: sidekiq_namespace) if sidekiq_namespace

    Sidekiq.configure_server do |s|
      s.redis = redis_config
    end

    Sidekiq.configure_client do |s|
      s.redis = redis_config
    end
    # Site.instance can fail when creating a new tenant
    begin
      app_url = Site.instance&.account&.cname if sidekiq_namespace
    rescue StandardError
      nil
    end
    app_url ||= Account.admin_host
    Sidekiq::Web.app_url = "https://#{app_url}"
    Sidekiq::Web.redis_pool = Sidekiq.redis_pool
  end

  def switch!
    Hyrax.config.redis_namespace = switchable_options[:namespace]
    sidekiq_namespace = ENV.fetch("SIDEKIQ_SPLIT_TENANTS", nil) ? switchable_options[:namespace] : nil
    RedisEndpoint.switch_sidekiq(sidekiq_namespace)
  end

  def ping
    redis_instance.ping
  rescue StandardError
    false
  end

  # Remove all the keys in Redis in this namespace, then destroy the record
  def remove!
    switch!
    # Redis::Namespace currently doesn't support flushall or flushdb.
    # See https://github.com/resque/redis-namespace/issues/56
    # So, instead we select all keys in current namespace and delete
    keys = redis_instance.keys '*'
    return if keys.empty?
    # Delete in slices to avoid "stack level too deep" errors for large numbers of keys
    # See https://github.com/redis/redis-rb/issues/122
    keys.each_slice(1000) { |key_slice| redis_instance.del(*key_slice) }
    destroy
  end

  private

    def redis_instance
      Hyrax::RedisEventStore.instance
    end
end
