class APIController < ApplicationController
  # Seconds before heartbeat ping is expired. This is double the frequency with
  # which clients should roughly be sending heartbeats, to account for any
  # connectivity issues.
  USER_HEARTBEAT_TTL = 360

  VOTES_KEY = "votes".freeze # Redis key for votes hash.

  # The recruit action is a POST request but we won't have a CSRF token.
  skip_before_action :verify_authenticity_token, only: [:recruit]

  # Set the number of active miners for use in views.
  before_action :set_n_miners, only: [:users]

  # Handle a miner's heartbeat by adding its key to the cache, checking the
  # n_recruits data, and and rendering the total amount donated and current
  # n_recruits data in response.
  def heartbeat
    output = { donated: Banker.total_donated_s }

    uuid = params[:uuid]
    if uuid
      $redis.with do |connection|
        connection.set(heartbeat_key(uuid), true, ex: USER_HEARTBEAT_TTL)
      end

      output["nRecruits"] = Recruit.n_recruits(uuid: uuid)
    end

    render json: output, content_type: Mime::JSON
  end

  # Handle a miner's un-heartbeat by removing the key from the cache.
  def unheartbeat
    uuid = params[:uuid]
    if uuid
      $redis.with { |connection| connection.del(heartbeat_key(uuid)) }
    end

    head :ok
  end

  # Count a user's vote (heart donation) for a particular charity.
  def vote
    charity = params[:charity]
    votes = params[:votes].to_i
    if charity.present? &&
       Charity::LIST.map(&:id).include?(charity) &&
       votes > 0
      # Increment votes for charity.
      $redis.with { |connection| connection.hincrby(VOTES_KEY, charity, votes) }
    end

    head :ok
  end

  # Render the number of votes for each charity.
  def votes
    render json: $redis.with { |connection| connection.hgetall(VOTES_KEY) }
  end

  # Serve the number of users who are currently running Compute for Humanity.
  def users
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, "\
                                        "must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

    render text: @n_miners, content_type: Mime::TEXT
  end

  def recruit
    if params[:uuid].present? && params[:email].present?
      RecruitingMailer.
        invite(address: params[:email], referral: params[:uuid]).
        deliver_now
    end

    head :ok
  end

  private

  # @return [String] the Redis key for storing the heartbeat ping
  def heartbeat_key(uuid)
    "heartbeat_#{uuid}"
  end
end
