Rails.application.reloader.to_prepare do
  SidekiqScheduler::RedisManager.key_prefix = "my-app"
end
