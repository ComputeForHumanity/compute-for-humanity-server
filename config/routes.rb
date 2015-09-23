Rails.application.routes.draw do
  root "home#home"
  get "/details" => "home#details"
  get "/financials" => "home#financials"
  get "/download" => "home#download"
  get "/users" => "home#users"
  get "/heartbeat" => "home#heartbeat"
  get "/unheartbeat" => "home#unheartbeat"
  get "/version" => "home#version"
  get "/release-notes" => "home#release_notes"
  post "/nicehash-update" => "home#nicehash_update"
  get "/payout-percentage" => "home#payout_percentage"
end
