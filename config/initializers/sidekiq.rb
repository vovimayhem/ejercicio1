# The Redis URL + Database number + namespace used to store the sidekiq queue data:
sidekiq_redis_url = "#{ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')}#{ENV.fetch('SIDEKIQ_STORE_PATH', '')}"

Sidekiq.configure_server do |config|
  config.redis = { url: sidekiq_redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: sidekiq_redis_url }
end
