# frozen_string_literal: true

class RedisEndpoint < Endpoint
  store :options, accessors: [:namespace]

  # Reset the Redis namespace back to the default value
  def self.reset!
    Hyrax.config.redis_namespace = Settings.redis.default_namespace
    # Sidekiq does not set namespace by default
    switch_sidekiq(nil)
  end

  def self.switch_sidekiq(namespace)
    yaml = YAML.safe_load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)
    config = yaml[Rails.env].with_indifferent_access
    redis_config = config.merge(thread_safe: true)
    redis_config = redis_config.merge(namespace: namespace) if namespace

    Sidekiq.configure_server do |s|
      s.redis = redis_config
    end

    Sidekiq.configure_client do |s|
      s.redis = redis_config
    end
  end

  def switch!
    Hyrax.config.redis_namespace = switchable_options[:namespace]
    RedisEndpoint.switch_sidekiq(switchable_options[:namespace])
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
