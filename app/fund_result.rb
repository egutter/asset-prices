require 'statsample'

class FundResult
	def initialize
		@funds = []
	end

	def add_fund(name, data_set)
		@funds << Fund.new(name, data_set)
	end

	def each
		@funds.each {|fund|
			yield fund
		}		
	end

	def fund_names
		@funds.map(&:name)
	end

	def from_date
		@funds.first.from_date
	end

	def to_date
		@funds.first.to_date
	end		

	def days_elapsed
		@funds.first.days_elapsed		
	end

	def join_summary(separator)
		result = ""
		@funds.each_with_index do |fund, index|
			 result << "'#{fund.name}', #{fund.sum}, #{fund.mean}, #{fund.max}, #{fund.min}, #{fund.stddev}, #{beta(fund.data_points.to_scale).round(2)}, #{fund.performance_in_days(30).round(2)}, #{fund.performance_in_days(60).round(2)}, #{fund.performance_in_days(90).round(2)}, #{fund.performance_in_days(360).round(2)}"
			 result << separator
		end
		result << "'MARKET INDEX', #{market_indexes.sum.round(2)}, #{market_indexes.mean.round(2)}, #{market_indexes.max.round(2)}, #{market_indexes.min.round(2)}, #{market_indexes.sd.round(2)}, #{beta(market_indexes).round(2)}, 0,0,0,0"
		result
	end

	def beta(rates_of_return)
		Statsample::Bivariate.covariance(market_indexes, rates_of_return) / market_indexes.variance
	end

	def market_indexes
		@market_indexes ||= @funds.map(&:data_points).transpose.map {|values| values.to_scale.mean }.to_scale
	end

	def render_motion_chart_rows
		result = ""
		@funds.each do |fund|
			fund.each_data_point do |data_point|
				result << "['#{fund.name}', new Date(#{data_point.ts.strftime('%Y,%m,%d')}), #{data_point.value}],"	
			end
			result
		end
		result
  end

	def render_cumulative_motion_chart_rows
		result = ""
		@funds.each do |fund|
			cumulative = 0.0
			fund.each_data_point do |data_point|
				cumulative += data_point.value 
				result << "['#{fund.name}', new Date(#{data_point.ts.strftime('%Y,%m,%d')}), #{cumulative}],"	
			end
			result
		end
		result
  end

	def join_data_points(separator)
		result = ""
		dp = data_points
		dp.each_with_index do |values, index|
			result << "'#{values.first.strftime('%d-%m')}',"
			result << values.last.join(',')
			result << separator if index < dp.size-1
		end
		result
	end

	def data_points
		result = {}
		@funds.each do |fund|
			fund.each_data_point do |data_point|
				result[data_point.ts] ||= []
				result[data_point.ts] << data_point.value
			end
		end
		result
	end

	def count
		@funds.size
	end

	def data_points_count
		@funds.first.data_size
	end

	class Fund
		attr_reader :name

		def initialize(name, data_set)
			@name, @data_set = name, data_set
		end

		def data_size
			@data_set.data.size
		end

		def each_data_point
			@data_set.data.each {|data_point| yield data_point}
		end

		def from_date
			@data_set.data.first.ts
		end

		def to_date
			@data_set.data.last.ts
		end

		def days_elapsed
			(to_date-from_date).to_i / (24 * 60 * 60)
		end

		def data_points
			@data_set.data.map(&:value)
		end

		def performance_in_days(days)
			(((1 + self.sum/100)**(days.to_f/days_elapsed.to_f))-1)*100
		end

		['sum', 'mean', 'max', 'min', 'stddev'].each do |summary_method|
			define_method(summary_method) do
				@data_set.summary.send(summary_method).round(2)
			end
		end

	end
end