class DailyReturn

  attr_reader :date, :value

  def initialize(date, value)
    @date, @value = date, value
  end
end