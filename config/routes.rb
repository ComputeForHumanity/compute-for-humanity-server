Rails.application.routes.draw do
  root "home#home"
  get "/details" => "home#details"
  get "/financials" => "home#financials"
  get "/download" => "home#download"
  get "/users" => "api#users"
  get "/heartbeat" => "api#heartbeat"
  get "/unheartbeat" => "api#unheartbeat"
  get "/version" => "api#version"
  get "/release-notes" => "home#release_notes"
end
