class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
