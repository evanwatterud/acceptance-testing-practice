require 'sinatra'
require 'csv'
require_relative "app/models/television_show"
require 'pry'

set :views, File.join(File.dirname(__FILE__), "app/views")

dupe_error = false
empty_error = false

get '/television_shows' do
  empty_error = false
  dupe_error = false
  @shows = []
  CSV.foreach("television-shows.csv", :headers => true) do |row|
    @shows << [row["title"], row["network"]]
  end
  erb :index
end

get '/television_shows/new' do
  @dupe_error = dupe_error
  @empty_error = empty_error
  erb :new
end

post '/television_shows' do
  CSV.foreach("television-shows.csv", :headers => true) do |row|
    if row["title"] == params["Title"]
      dupe_error = true
      redirect '/television_shows/new'
    end
  end

  if params["Title"].empty? || params["Network"].empty? || params["Starting Year"].empty? || params["Synopsis"].empty?
    empty_error = true
    redirect '/television_shows/new'
  end
  CSV.open("television-shows.csv", "a+") do |csv|
    csv << [params["Title"], params["Network"], params["Starting Year"], params["Synopsis"], params["Genre"]]
  end
  redirect '/television_shows'
end
