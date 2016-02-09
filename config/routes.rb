Rails.application.routes.draw do
  root "home#home"
  get "/details" => "home#details"
  get "/financials" => "home#financials"
  get "/download" => "home#download"
  get "/release-notes" => "home#release_notes"

  get "/_download" => "download#download"

  get "/heartbeat" => "old_api#heartbeat"
  get "/unheartbeat" => "old_api#unheartbeat"
  get "/version" => "old_api#version"

  get "/api/v1/users" => "api#users"
  get "/api/v1/heartbeat" => "api#heartbeat"
  get "/api/v1/unheartbeat" => "api#unheartbeat"
  get "/api/v1/vote" => "api#vote"
end
