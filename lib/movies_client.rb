require 'net/http'
require 'uri'
require 'json'
require 'redis'

class MoviesClient
  def self.search(query, page)
    new.search(query, page)
  end

  def search(query, page)
    @query = query.downcase
    @page = page

    cache_hit = redis_client.exists?(cache_key)
    response = cache_hit ? hit_cache : miss_cache
    
    parsed_response = JSON.parse(response)
    
    movies = parsed_response['results']
    total_pages = parsed_response['total_pages']

    [ movies, total_pages, cache_hit ]
  end

  private

  def cache_key
    "#{@query}:#{@page}"
  end

  def call_tmdb_api
    url = tmdb_url
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'

    response = http.request(request)

    response.read_body
  end

  def hit_cache
    redis_client.hincrby(cache_key, "hit_count", 1)
    redis_client.hget(cache_key, "cached_response")
  end

  def miss_cache
    response_string = call_tmdb_api

    redis_client.hmset(cache_key, "cached_response", response_string, "hit_count", 0)
    redis_client.expire(cache_key, ENV['CACHE_EXPIRY'])

    response_string
  end

  def tmdb_url
    encoded_query = URI.encode_www_form_component(@query)
    base_url = ENV['BASE_TMDB_URL']
    api_key = ENV['TMDB_API_KEY']

    URI("#{base_url}?query=#{encoded_query}&page=#{@page}&api_key=#{api_key}")
  end

  def redis_client
    @_redis_client ||= Redis.new(url: "#{ENV['REDIS_URL']}/#{ENV['REDIS_DB_NUMBER']}")
  end
end
