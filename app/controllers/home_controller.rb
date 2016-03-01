class HomeController < ApplicationController
  # Set the number of active miners for use in views.
  before_action :set_n_miners,
                only: [:home, :faq, :details, :financials, :download]

  def home
  end

  def details
  end

  def faq
  end

  def financials
    @donations = Donation.order(created_at: :desc)
    @exchanges = Exchange.order(created_at: :desc)
  end

  def download
  end

  def release_notes
    @version = params[:version]

    render "release_notes", layout: nil
  end
end
