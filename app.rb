# frozen_string_literal: true

require 'bundler/setup'
require 'sinatra'
require_relative './lib/getpocket'

CONSUMER_KEY = ENV['GETPOCKET_CONSUMER_KEY']

set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
enable :sessions

helpers do
  def authorized?
    !session['access_token'].nil?
  end

  def articles
    return [] unless authorized?

    getpocket.get_articles(count: 1000, offset: 0).to_a.shuffle
  end

  def getpocket
    @getpocket ||= GetPocket.new(
      ENV['GETPOCKET_REDIRECT_HOST'],
      CONSUMER_KEY, session['access_token']
    )
  end
end

get '/' do
  if authorized?
    redirect to('/articles')
  else
    erb :auth
  end
end

get '/articles' do
  if !authorized?
    redirect to('/')
  else
    cache_control :public, max_age: 60 * 60 * 24
    erb :articles
  end
end

get '/getpocket/get_request_token' do
  session['request_token'] = getpocket.obtain_request_token
  redirect getpocket.authorize_url
end

get '/getpocket/auth_done' do
  session['access_token'] = getpocket.obtain_access_token(session['request_token'])
  redirect to('/')
end
