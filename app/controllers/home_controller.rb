class HomeController < ApplicationController
  APP_VERSION = "1.8"

  # Seconds before heartbeat ping is expired. This is double the frequency with
  # which clients should roughly be sending heartbeats, to account for any
  # connectivity issues.
  USER_HEARTBEAT_TTL = 360

  PAYOUT_PERCENTAGE_KEY = "nicehash_payout_percentage"

  # Set the donation value for all HTML views.
  before_action :set_donation_total,
                only: [:home, :details, :financials, :download, :heartbeat]

  # Set the number of active miners for use in views.
  before_action :set_n_miners,
                only: [:home, :details, :financials, :download, :users]

  skip_before_action :verify_authenticity_token, :nicehash_update

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
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, "\
                                        "must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

    render text: @n_miners, content_type: Mime::TEXT
  end

  def release_notes
    @version = params[:version]

    render "release_notes", layout: nil
  end

  # Store the percentage of the way we are toward a payout.
  def nicehash_update
    $redis.with do |connection|
      connection.set(
        PAYOUT_PERCENTAGE_KEY,
        Banker.payout_completion_percentage(
          unpaid_balance: nicehash_unpaid_balance
        )
      )
    end

    head :ok
  end

  # Renders the percentage of the way we are toward a payout.
  def payout_percentage
    render text: $redis.with { |conn| conn.get(PAYOUT_PERCENTAGE_KEY) },
           content_type: Mime::TEXT
  end

  private

  # Enforce params from the NiceHash update webhook being formatted correctly.
  # @return [Money] the unpaid balance from the request
  def nicehash_unpaid_balance
    unpaid_balance_s = params.
                       require(:results).
                       permit("standaloneData" => ["unpaidBalanceBTC"]).
                       require("standaloneData").
                       first["unpaidBalanceBTC"]

    match = unpaid_balance_s.match /\A\d\.(\d{8})\z/
    raise "Bad input" unless match

    Money.new(match[1], "BTC")
  end

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
