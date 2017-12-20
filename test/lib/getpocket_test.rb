# frozen_string_literal: true

require 'test_helper'
require 'securerandom'

class GetpocketTest < Minitest::Test
  def subject
    @subject ||= ::GetPocket.new(host, consumer_key)
  end

  def consumer_key
    @consumer_key ||= "consumer-key-#{SecureRandom.hex(4)}"
  end

  def host
    @host ||= "host-#{SecureRandom.hex(4)}"
  end

  def redirect_uri
    "http://#{host}/getpocket/auth_done"
  end

  def request_token
    @request_token ||= "request-token-#{SecureRandom.hex(4)}"
  end

  def default_headers
    {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Ruby',
      'Host' => 'getpocket.com'
    }
  end

  def stub_request_token_request
    stub_request(
      :post,
      'https://getpocket.com/v3/oauth/request'
    ).with(
      body: {
        consumer_key: consumer_key,
        redirect_uri: redirect_uri
      }.to_json,
      headers: default_headers.merge(
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Accept' => 'application/json'
      )
    ).to_return(
      body: {
        code: request_token
      }.to_json
    )
  end

  def test_it_obtains_request_token
    stub_request_token_request

    token = subject.obtain_request_token

    assert_equal request_token, token
  end

  def test_authorize_url_crafts_correct_url
    stub_request_token_request

    access_token_url = 'https://getpocket.com/auth/authorize?'\
      "request_token=#{request_token}&redirect_uri=#{URI.encode_www_form_component(redirect_uri)}"

    assert_equal access_token_url, subject.authorize_url
  end
end
