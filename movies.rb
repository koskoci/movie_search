require 'sinatra'
require 'dotenv'
require './lib/movies_client.rb'

Dotenv.load

get '/' do
  erb :index, locals: { movies_on_page: [], query: nil }
end

get '/search' do
  query = params[:query]
  current_page = params[:page]&.to_i
  movies_on_page, total_pages, cache_hit = MoviesClient.search(query, current_page)
  previous_page_url = previous_page_url_for(query, current_page)
  next_page_url = next_page_url_for(query, current_page)
  first_page = current_page == 1
  last_page = current_page == total_pages

  view_model = {
    query: query,
    current_page: current_page,
    movies_on_page: movies_on_page,
    total_pages: total_pages,
    cache_hit: cache_hit,
    previous_page_url: previous_page_url,
    next_page_url: next_page_url,
    first_page: first_page,
    last_page: last_page
  }

  erb :index, locals: view_model
end

helpers do
  def image_url_for(movie)
    "https://image.tmdb.org/t/p/w300#{movie["poster_path"]}"
  end
end

private

def previous_page_url_for(query, current_page)
  "/search?query=#{query}&page=#{current_page - 1}"
end

def next_page_url_for(query, current_page)
  "/search?query=#{query}&page=#{current_page + 1}"
end
