class DailyReturn

  attr_reader :date, :value, :adjusted_close, :open, :high, :low, :close, :volume

  def initialize(date, value, adjusted_close, open, high, low, close, volume)
    @date, @value, @adjusted_close = date, value, adjusted_close
    @open, @high, @low, @close, @volume = open, high, low, close, volume
  end
end