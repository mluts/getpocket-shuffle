# frozen_string_literal: true

require 'bundler/setup'
require 'sinatra'
require_relative './lib/getpocket'

CONSUMER_KEY = IO.read(File.expand_path('~/.getpocket-consumer-key')).strip.freeze

enable :sessions

helpers do
  def authorized?
    !session['access_token'].nil?
  end
end

get '/' do
  erb :index
end

get '/getpocket/get_request_token' do
  getpocket = GetPocket.new('u1.vpn:9292', CONSUMER_KEY)
  session['request_token'] = getpocket.obtain_request_token
  redirect getpocket.authorize_url
end

get '/getpocket/auth_done' do
  getpocket = GetPocket.new('u1.vpn:9292', CONSUMER_KEY)
  session['access_token'] = getpocket.obtain_access_token(session['request_token'])
  redirect to('/')
end
