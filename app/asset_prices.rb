require 'sinatra'
require "#{File.dirname(__FILE__)}/tempo_db_repository"

configure :development do
	ENV['TEMPODB_API_HOST']= 'api.tempo-db.com' 
	ENV['TEMPODB_API_KEY']= '4e1f2d7394f54886b2f7b7a10e6647b6' 
	ENV['TEMPODB_API_PORT']= '443' 
	ENV['TEMPODB_API_SECRET']= '979fd9f0fac942d5868c2accd2772b2c' 
	ENV['TEMPODB_API_SECURE']= 'True'
end

get '/' do
	@assets = TempoDbRepository.new().all_funds_from(Time.utc(2013, 1, 1))
  haml :index
end