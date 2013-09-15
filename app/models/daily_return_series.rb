class DailyReturnSeries

  attr_reader :asset_name, :daily_returns
  alias_method :name, :asset_name

  def initialize(asset_name, daily_returns, stats_calculator)
    @asset_name, @daily_returns = asset_name, daily_returns
    @stats_calculator = stats_calculator
  end

  def size
    @daily_returns.size
  end

  def each_daily_return
    @daily_returns.each { |daily_return|
      yield daily_return
    }
  end

  def days
    @daily_returns.map(&:date)
  end

  def series_start_date
    @daily_returns.first.date
  end

  def series_end_date
    @daily_returns.last.date
  end

  def days_elapsed
    (series_end_date-series_start_date).to_i / (24 * 60 * 60)
  end

  def daily_return_values
    @daily_returns.map(&:value).to_scale
  end

  def performance_in_days(days)
    @stats_calculator.performance_in_days(self, days)
  end

  def beta(market_index = self)
    @beta ||= @stats_calculator.beta(self, market_index)
  end

  def include_date?(a_date)
    @daily_returns.any? {|dr| dr.date == a_date}
  end

  ['sum', 'mean', 'max', 'min', 'stddev', 'sharpe_ratio', 'sortino_ratio', 'total_return'].each do |stats_method|
    define_method(stats_method) do
      cached_value = instance_variable_get("@#{stats_method}")
      return cached_value if cached_value
      result = @stats_calculator.send(stats_method, self)
      instance_variable_set("@#{stats_method}", result)
    end
  end
end