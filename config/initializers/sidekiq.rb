config = YAML.load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)[Rails.env].with_indifferent_access
redis_config = config.merge(thread_safe: true)
redis_config = redis_config.merge(namespace: ENV.fetch('SIDEKIQ_NAMESPACE')) if ENV.fetch('SIDEKIQ_NAMESPACE', nil)

Sidekiq.configure_server do |s|
  s.redis = redis_config
end

Sidekiq.configure_client do |s|
  s.redis = redis_config
end
