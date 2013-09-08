class TempoDbMarketIndexBuilder

  def self.build(asset_series)
    matrix = asset_series.map{|series| series.daily_returns.to_a }.transpose
    daily_returns = matrix.map {|each_day| DailyReturn.new(each_day.first.date, each_day.map(&:value).to_scale.mean) }
    DailyReturnSeries.new Asset::SANTANDER_FUNDS_MARKET_INDEX, daily_returns, StatsCalculator.new
  end


end