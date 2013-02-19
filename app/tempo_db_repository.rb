require 'tempodb'
require "#{File.dirname(__FILE__)}/fund_result"

class TempoDbRepository

  def initialize(config = {})
    api_key = config[:api_key] || ENV['TEMPODB_API_KEY']
    api_secret = config[:api_secret] || ENV['TEMPODB_API_SECRET']
    api_host = config[:api_host] || ENV['TEMPODB_API_HOST']
    api_port = Integer(config[:api_port] || ENV['TEMPODB_API_PORT'])
    api_secure = (config[:api_secure] || ENV['TEMPODB_API_SECURE']) == "False" ? false : true

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

  def has_values_at?(ts)
    !read_at(ts).map(&:data).flatten.empty?
  end

  def read_at(ts)
    @client.read(Time.utc(ts.year, ts.month, ts.day, 0, 0, 0), Time.utc(ts.year, ts.month, ts.day, 23, 59, 59))
  end

  def all_funds_from(start)
    result = FundResult.new  
    get_series.collect do |series|
      result.add_fund(series.key, get_data_sets(series, start))
    end
    result
  end

  private

  def get_data_sets(series, start)
    @client.read_id(series.id, start, Time.now)
  end

  def get_series
    @client.get_series
  end  
end

