require 'tempodb'

class TempoDbRepository

  def initialize
    api_key = ENV['TEMPODB_API_KEY']
    api_secret = ENV['TEMPODB_API_SECRET']
    api_host = ENV['TEMPODB_API_HOST']
    api_port = Integer(ENV['TEMPODB_API_PORT'])
    api_secure = ENV['TEMPODB_API_SECURE'] == "False" ? false : true

    @client = TempoDB::Client.new( api_key, api_secret, api_host, api_port, api_secure )
  end

  def start_at(data_point_ts)
    @records = Array.new
    @data_point_ts = data_point_ts
  end

  def add_fund_delta(fund_delta)
    @records << {:key => fund_delta.name, :v => fund_delta.daily_delta}
  end
  
  def commit
    @client.write_bulk(@data_point_ts, @records) 
  end
end

