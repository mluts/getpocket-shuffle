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

  def test_it_obtains_request_token
    stub_request(
      :post,
      'https://getpocket.com/v3/oauth/request'
    ).with(
      body: {
        consumer_key: consumer_key,
        redirect_uri: "http://#{host}/getpocket/auth_done"
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

    token = subject.obtain_request_token
    assert_equal request_token, token
  end
end
