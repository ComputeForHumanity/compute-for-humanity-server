Rails.application.routes.draw do
  root "home#home"
  get "/details" => "home#details"
  get "/financials" => "home#financials"
  get "/download" => "home#download"
  get "/users" => "home#users"
  get "/heartbeat" => "home#heartbeat"
  get "unheartbeat" => "home#unheartbeat"
  get "/version" => "home#version"
  get "release-notes/:version" => "home#release_notes"
end
