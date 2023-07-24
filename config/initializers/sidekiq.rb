Rails.application.reloader.to_prepare do
  SidekiqScheduler::RedisManager.key_prefix = "draftordie"
end
Sidekiq.configure_server do |config|
  config.logger.level = Rails.logger.level
end
