class BlogController < ApplicationController
  # Set the number of active miners for use in views.
  before_action :set_n_miners, only: [:index, "1"]
end
