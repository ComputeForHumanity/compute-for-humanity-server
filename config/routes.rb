Rails.application.routes.draw do
  root "home#home"
  get "/details" => "home#details"
  get "/financials" => "home#financials"
  get "/privacy" => "home#privacy"
  get "/download" => "home#download"
  get "/faq" => "home#faq"
  get "/release-notes" => "home#release_notes"

  get "/heartbeat" => "old_api#heartbeat"
  get "/unheartbeat" => "old_api#unheartbeat"
  get "/version" => "old_api#version"

  get "/api/v1/users" => "api#users"
  get "/api/v1/heartbeat" => "api#heartbeat"
  get "/api/v1/unheartbeat" => "api#unheartbeat"
  get "/api/v1/vote" => "api#vote"
  get "/api/v1/votes" => "api#votes"
  get "/api/v1/recruits" => "api#recruits"

  get "/blog" => "blog#index"
  get "/blog/introducing-2.0" => "blog#1", as: :blog_1
  get "/blog/out-of-pocket-developer" => "blog#2", as: :blog_2
  get "/blog/a-non-blog-blog" => "blog#3", as: :blog_3
  get "/blog/saying-goodbye" => "blog#4", as: :blog_4
end
