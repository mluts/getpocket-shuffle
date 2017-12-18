# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

# https://getpocket.com/developer/
class GetPocket
  Error = Class.new(::StandardError)

  def initialize(host, consumer_key, access_key = nil)
    @host = host
    @consumer_key = consumer_key
    @access_key = access_key
  end

  def obtain_access_token
  end

  def obtain_request_token
    json = post!(
      '/v3/oauth/request',
      consumer_key: @consumer_key,
      redirect_uri: "http://#{@host}/getpocket/auth_done"
    )

    @request_token = json['code'] || raise(Error, 'Request Code not present')
  end

  private

  def post!(path, params = {})
    uri = make_uri(path)

    request = Net::HTTP::Post.new(uri)
    request.body = params.to_json
    request.content_type = 'application/json; charset=UTF-8'
    request['X-Accept'] = 'application/json'

    response = perform_request(request)
    check_response!(response)

    JSON.parse(response.body)
  end

  def make_uri(path)
    URI("https://getpocket.com#{path}")
  end

  def perform_request(request)
    uri = request.uri

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
  end

  def check_response!(response)
    return if response.is_a?(Net::HTTPSuccess)

    raise(
      Error,
      "Unexpected response. #{response.class} #{response.code} #{response.message} #{response.body}"
    )
  end
end
