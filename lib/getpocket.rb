# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

# https://getpocket.com/developer/
class GetPocket
  Error = Class.new(::StandardError)

  SORT_NEWEST = 'newest'
  SORT_OLDEST = 'oldest'

  # Article Item
  class Article
    def initialize(json)
      @json = json.to_h
    end

    def id
      @json['item_id']
    end

    def to_json(*args)
      @json.to_json(*args)
    end

    def ==(other)
      json == other.json
    end

    attr_reader :json
    protected :json
  end

  def initialize(host, consumer_key, access_token = nil)
    @host = host
    @consumer_key = consumer_key
    @access_token = access_token
  end

  def obtain_access_token(request_token)
    json = post!(
      '/v3/oauth/authorize',
      consumer_key: @consumer_key,
      code: request_token
    )

    @access_token = json['access_token'] || raise(Error, 'Access Token not present')
  end

  def obtain_request_token
    @request_token ||=
      begin
        json = post!(
          '/v3/oauth/request',
          consumer_key: @consumer_key,
          redirect_uri: redirect_uri
        )

        json['code'] || raise(Error, 'Request Code not present')
      end
  end

  def authorize_url
    obtain_request_token

    format(
      'https://getpocket.com/auth/authorize?request_token=%s&redirect_uri=%s',
      escape(@request_token),
      escape(redirect_uri)
    )
  end

  def redirect_uri
    "http://#{@host}/getpocket/auth_done"
  end

  def get_articles(count: 10, offset: 0, sort: SORT_NEWEST)
    json = post!(
      '/v3/get',
      access_token: @access_token,
      consumer_key: @consumer_key,
      count: count,
      offset: offset,
      sort: sort
    )

    json['list'].lazy.map { |item| Article.new(item) }
  end

  private

  def escape(str)
    URI.encode_www_form_component(str)
  end

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
