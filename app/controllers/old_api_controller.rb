class OldAPIController < ApplicationController
  APP_VERSION = "2.1".freeze

  # Seconds before heartbeat ping is expired. This is double the frequency with
  # which clients should roughly be sending heartbeats, to account for any
  # connectivity issues.
  USER_HEARTBEAT_TTL = 360

  # Handle a miner's heartbeat by adding its key to the cache, and rendering the
  # total amount donated in response.
  def heartbeat
    uuid = params[:id]
    if uuid
      $redis.with do |connection|
        connection.set(heartbeat_key(uuid), true, ex: USER_HEARTBEAT_TTL)
      end
    end

    render text: Banker.total_donated_s, content_type: Mime::TEXT
  end

  # Handle a miner's un-heartbeat by removing the key from the cache.
  def unheartbeat
    uuid = params[:id]
    if uuid
      $redis.with { |connection| connection.del(heartbeat_key(uuid)) }
    end

    head :ok
  end

  def version
    render text: APP_VERSION, content_type: Mime::TEXT
  end

  private

  # @return [String] the Redis key for storing the heartbeat ping
  def heartbeat_key(uuid)
    "heartbeat_#{uuid}"
  end
end
