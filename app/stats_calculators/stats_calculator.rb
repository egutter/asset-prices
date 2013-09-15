require 'statsample'

class StatsCalculator

  def sharpe_ratio(series)
    self.stddev(series).zero? ? 0 : (Math.sqrt(250) * (self.mean(series) / self.stddev(series))).round(4)
  end

  def sortino_ratio(series)
    mean = self.mean(series)
    dr = downside_risk(series, mean)
    dr.zero? ? 0 : (Math.sqrt(250) * (mean / dr)).round(4)
  end

  def downside_risk(series, mean)
    sdev = series.daily_return_values.inject(0) { |sum, daily_return|
      factor = (daily_return < 0) ? 1 : 0
      sum + (((daily_return - mean) ** 2) * factor)
    }
    Math.sqrt(sdev / series.size)
  end

  def beta(series, market_indexes)

    if (market_indexes.size != series.size)
      days_to_include = series.days & market_indexes.days
      series_daily_return_values = series.daily_returns.select {|series_daily_return| days_to_include.include? series_daily_return.date}.map(&:value).to_scale
      index_daily_return_values = market_indexes.daily_returns.select {|index_daily_return| days_to_include.include? index_daily_return.date}.map(&:value).to_scale
    else
      series_daily_return_values = series.daily_return_values
      index_daily_return_values = market_indexes.daily_return_values
    end
    (Statsample::Bivariate.covariance(index_daily_return_values, series_daily_return_values) / index_daily_return_values.variance).round(4)
 	end

  def performance_in_days(series, days)
    ((((1 + series.total_return)**(days.to_f/series.days_elapsed.to_f))-1)).round(4)
  end

  def stddev(series)
    series.daily_return_values.sd.round(2)
  end

  def total_return(series)
    (series.daily_return_values.inject(1) {|memo, daily_return| memo * (1 + daily_return) } - 1).round(4)
  end

  ['sum', 'mean', 'max', 'min'].each do |summary_method|
    define_method(summary_method) do |series|
      series.daily_return_values.send(summary_method).round(4)
    end
  end
end