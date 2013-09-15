class TempoDbDailyReturnAdapter

  def initialize(data_set)
    @data_set = data_set
  end

  def size
    @data_set.data.size
  end

  def each
    @data_set.data.each {|data_point| yield DailyReturn.new(data_point.ts, data_point.value/100) }
  end

  def map
    @data_set.data.map {|data_point| yield DailyReturn.new(data_point.ts, data_point.value/100) }
  end

  def to_a
    @data_set.data.map {|data_point| DailyReturn.new(data_point.ts, data_point.value/100) }
  end

  def summary
    @data_set.summary
  end

  def first
    first_data_set = @data_set.data.first
    DailyReturn.new(first_data_set.ts, first_data_set.value/100)
  end

  def last
    last_data_set = @data_set.data.last
    DailyReturn.new(last_data_set.ts, last_data_set.value/100)
  end
end