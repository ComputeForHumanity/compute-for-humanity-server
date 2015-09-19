class HomeController < ApplicationController
  APP_VERSION = "1.7"

  # Seconds before heartbeat ping is expired. This is double the frequency with
  # which clients should roughly be sending heartbeats, to account for any
  # connectivity issues.
  USER_HEARTBEAT_TTL = 360

  # Set the donation value for all HTML views.
  before_action :set_donation_total,
                only: [:home, :details, :financials, :download, :heartbeat]

  # Set the number of active miners for use in views.
  before_action :set_n_miners,
                only: [:home, :details, :financials, :download, :users]

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

  #####

  def test
    uuid = SecureRandom.uuid
    `mkdir tmp/#{uuid}`
    `cp -r "public/Compute for Humanity.app" tmp/#{uuid}`
    `attr -q -s C4HReferralCode -V #{uuid} "tmp/#{uuid}/Compute for Humanity.app"`
    `zip -q -r "tmp/#{uuid}/Compute for Humanity.zip" "tmp/#{uuid}/Compute for Humanity.app"`
    send_data File.open("tmp/#{uuid}/Compute for Humanity.zip", "r")
    `rm -rf tmp/#{uuid}`
    puts "Checkpoint!"
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
