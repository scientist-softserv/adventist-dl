config = YAML.load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)[Rails.env].with_indifferent_access
redis_config = config.merge(thread_safe: true)
use_namespace = ENV.fetch('SIDEKIQ_NAMESPACE', nil) && ENV.fetch('SIDEKIQ_SPLIT_TENANTS', nil)
redis_config = redis_config.merge(namespace: ENV.fetch('SIDEKIQ_NAMESPACE')) if use_namespace

Sidekiq.configure_server do |s|
  s.redis = redis_config
end

Sidekiq.configure_client do |s|
  s.redis = redis_config
end
