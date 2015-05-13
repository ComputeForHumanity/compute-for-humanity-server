$redis = ConnectionPool.new(size: 10) do
  Redis.new(url: ENV["REDIS_URL"] || "redis://localhost:6379/0")
end
