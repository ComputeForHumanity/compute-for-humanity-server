workers Integer(ENV["WEB_CONCURRENCY"] || 2)
threads_count = Integer(ENV["MAX_THREADS"] || 5)
threads threads_count, threads_count

preload_app!

rackup DefaultRackup
port ENV["PORT"] || 3000
environment ENV["RACK_ENV"] || "development"

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection

  redis_connections_per_process = Integer(ENV["REDIS_CONNS_PER_PROCESS"] || 5)
  $redis = ConnectionPool.new(size: redis_connections_per_process) do
    Redis.new(url: ENV["REDIS_URL"] || "redis://localhost:6379/0")
  end
end
