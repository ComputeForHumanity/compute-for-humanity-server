class DownloadController < ApplicationController
  def download
    uuid = params[:r]

    Recruit.increment(uuid: uuid) if uuid.present?

    send_file "public/Compute for Humanity.zip"
  end
end
