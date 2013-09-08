class YahooFinanceRepository

  ONE_DAY = 60 * 60 * 24

  def merval_index(from_date)
    all_daily_returns_filter_by(from_date, [Asset::MERVAL_MARKET_INDEX]).first
  end

  def all_daily_returns_from(start, symbols, index)
    all_daily_returns_filter_by(start, symbols)
  end

  def all_daily_returns_filter_by(start, symbols)
    days = ((Time.now-start)/ONE_DAY).to_i
    symbols.map do |symbol|
      daily_returns = []
      result = YahooFinance::get_historical_quotes_days(symbol, days ).reverse
      last_close_price = 0
      first = true
      result.each { |row|
        date_values = row[0].split('-')
        price_date = Time.mktime(date_values[0].to_i, date_values[1].to_i, date_values[2].to_i)
        if first
          last_close_price = row[6].to_f
          first = false
          next
        else
          daily_return = (((row[6].to_f/last_close_price)-1)*100).round(2)
          last_close_price = row[6].to_f
          daily_returns << DailyReturn.new(price_date, daily_return)
        end
      }
      DailyReturnSeries.new(symbol, daily_returns, StatsCalculator.new)
    end
  end

  class AlwaysIncludeFilter
    def exclude?(a_date)
      false
    end
  end

  class ExcludeWhenNotPresentInIndex
    def initialize(index)
      @index = index
    end

    def exclude?(a_date)
      !@index.days.include?(a_date)
    end
  end

  class DoNotFillAnything
    def fill_missing_gaps_in_days(daily_returns)
      #do nothing
      daily_returns
    end
    def fill_missing_days_at_end(daily_returns)
      #do nothing
      daily_returns
    end
  end

  class FillMissingDaysInIndex
    def initialize(index)
      @index = index
    end

    def fill_missing_days_at_end(daily_returns)
      result = daily_returns.clone
      if daily_returns.size < @index.daily_returns.size
        last_date = daily_returns.last.date
        days_to_fill = (@index.daily_returns.last.date - last_date) / (60*60*24)
        days_to_fill.to_i.times { |days|
          missing_date = last_date + (60*60*24*(days+1))
          result << DailyReturn.new(missing_date, 0.0)
        }
      end
      result
    end

    def fill_missing_gaps_in_days(daily_returns)
      result = []
      @index.daily_returns.zip(daily_returns).each do |tuple|
        break if tuple.last.nil?
        #if tuple.first.date == tuple.last.date
        #  result << tuple.last
        if tuple.first.date < tuple.last.date
            start_date = tuple.first.date
          begin
            result << DailyReturn.new(start_date, 0.0)
            start_date += 60*60*24
          end while start_date < tuple.last.date
        end
        result << tuple.last
      end
      result
    end
  end
end