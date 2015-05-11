class DwollaSecret < ActiveRecord::Base
  validates :refresh_token, :encrypted_pin, presence: true

  attr_encrypted :pin,
                 key: Rails.application.secrets.secret_key_base,
                 mode: :per_attribute_iv_and_salt

  # Refreshes the access token using the refresh token, and updates the database
  # to store the new refresh token.
  # @return [String] the new oauth access token
  def oauth_token!
    Dwolla::api_key = ENV["DWOLLA_API_KEY"]
    Dwolla::api_secret = ENV["DWOLLA_API_SECRET"]

    refresh_response = Dwolla::OAuth.refresh_auth(refresh_token)

    update!(refresh_token: refresh_response["refresh_token"])

    refresh_response["access_token"]
  end

  # @return [String] the new oauth access token
  def self.oauth_token!
    first.oauth_token!
  end

  # @return [String] the decrypted PIN
  def self.pin
    first.pin
  end
end
