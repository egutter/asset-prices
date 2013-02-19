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

	def join_summary(separator)
		result = ""
		@funds.each_with_index do |fund, index|
			 result << "'#{fund.name}', #{fund.data_size}, #{fund.sum}, #{fund.mean}, #{fund.max}, #{fund.min}, #{fund.stddev}"
			 result << separator if index < @funds.size-1
		end
		result
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
		# ['Apples',  new Date (1988,0,1), 1000, 300, 'East'],
  #         ['Oranges', new Date (1988,0,1), 1150, 200, 'West'],
  #         ['Bananas', new Date (1988,0,1), 300,  250, 'West'],
  #         ['Apples',  new Date (1989,6,1), 1200, 400, 'East'],
  #         ['Oranges', new Date (1989,6,1), 750,  150, 'West'],
  #         ['Bananas', new Date (1989,6,1), 788,  617, 'West']
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

		['sum', 'mean', 'max', 'min', 'stddev'].each do |summary_method|
			define_method(summary_method) do
				@data_set.summary.send(summary_method).round(2)
			end
		end

	end
end