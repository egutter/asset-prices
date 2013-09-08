class TempoDbStatsCalculator < StatsCalculator
  ['sum', 'mean', 'max', 'min', 'stddev'].each do |summary_method|
    define_method(summary_method) do |series|
      series.daily_returns.summary.send(summary_method).round(2)
    end
  end
end