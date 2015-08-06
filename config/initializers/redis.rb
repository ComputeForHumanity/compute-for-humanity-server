$redis = ConnectionPool.new(size: Integer(ENV["REDIS_CONNECTIONS"] || 5)) do
  Redis.new(url: ENV["REDISCLOUD_URL"] || "redis://localhost:6379/0")
end
