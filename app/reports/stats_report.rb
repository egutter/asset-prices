class StatsReport
  def initialize(*markets)
    @markets = markets
  end

  def add_filter_by_names(names_to_include)
    @names_to_include = names_to_include
    self
  end

  def days
    @markets.max {|market_a, market_b|
      market_a.days.size <=> market_b.days.size
    }.days.map { |day| day.strftime('%d/%m') }
  end

  def daily_returns_series
    filtered_assets.map do |asset|
      {name: asset.asset_name, data: []}
    end
  end

  def daily_returns_to_json
    filtered_assets.map do |asset|
      {name: asset.asset_name,
       data: asset.daily_returns.map do |daily_return|
         [daily_return.date, daily_return.value.round(2)]
       end
      }
    end
  end

  def cumulative_daily_returns_to_json
    filtered_assets.map do |asset|
      cumulative = 1
      {name: asset.asset_name,
       data: asset.daily_returns.map do |daily_return|
         cumulative = cumulative * (1 + daily_return.value)
         [daily_return.date, cumulative.round(2)]
       end
      }
    end
  end

  def filtered_assets
    @markets.collect do |market|
      market.assets_with_index.select do |series|
        @names_to_include.include?(series.name)
      end
    end.flatten
  end

  def dates_step
    (days_elapsed/30).to_i + 10
  end

  def each
    filtered_assets.each { |fund|
        yield fund
    }
  end

  def fund_names
    filtered_assets.map(&:name)
  end

  def from_date
    filtered_assets.first.series_start_date
  end

  def to_date
    filtered_assets.first.series_end_date
  end

  def days_elapsed
    filtered_assets.first.days_elapsed
  end

  def count
    filtered_assets.size
  end

  def data_points_count
    filtered_assets.first.size
  end

end