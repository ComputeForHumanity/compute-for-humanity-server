class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # If we're in production, redirect non-www to www subdomains.
  before_action do
    if Rails.env.production? && request.host[0..3] != "www."
      redirect_to "https://www.computeforhumanity.org#{request.fullpath}",
                  status: 301
    end
  end

  private

  def default_url_options
    options = {}
    options[:r] = params[:r] if params[:r].present?
    options.merge(super)
  end

  def set_n_miners
    @n_miners = $redis.with(&:dbsize) - 1 # Subtract one for votes hash.
  end
end
