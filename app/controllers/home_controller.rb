class HomeController < ApplicationController
  APP_VERSION = "1.3"
  USER_HEARTBEAT_TTL = 120 # Seconds before heartbeat ping is expired.

  # Set the donation value for all HTML views and the /donated route.
  before_action :set_donation_total, except: [:version, :users, :latest]

  # Set the number of active miners for use in views.
  before_action :set_n_miners, except: [:version, :heartbeat, :latest]

  def home
  end

  def details
  end

  def financials
    @donations = Donation.order(created_at: :desc)
    @exchanges = Exchange.order(created_at: :desc)
  end

  def download
  end

  # Handle a miner's heartbeat by adding its key to the cache, and rendering the
  # total amount donated in response.
  def heartbeat
    uuid = params[:id]
    if uuid
      $redis.with do |connection|
        connection.set(heartbeat_key(uuid), true, ex: USER_HEARTBEAT_TTL)
      end
    end

    render text: @total_donated, content_type: Mime::TEXT
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

  def users
    render text: @n_miners, content_type: Mime::TEXT
  end

  private

  # @return [String] the Redis key for storing the heartbeat ping
  def heartbeat_key(uuid)
    "heartbeat_#{uuid}"
  end

  # Set the @total_donated value to how much has been donated so far.
  def set_donation_total
    @total_donated = Banker.total_donated_s
  end

  def set_n_miners
    @n_miners = $redis.with(&:dbsize)
  end
end
