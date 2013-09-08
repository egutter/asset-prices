require 'nokogiri'
require 'open-uri'

class Object
  def try(method)
    self.send(method) unless self.nil?
  end
end

class SantanderFundsImporter

  FundDelta = Struct.new(:name, :daily_delta)

  FUNDS_TO_EXCLUDE = ['Fondo', 'SUP AMERICA REEXPRESADO EN PESOS C','SUP EUROPA C REEX EN PESOS', 'SUPERFONDO BRIC REEX EN $ C',
                      'SUPERGESTION INT EUROPA E PESOS', 'SUPERFONDO RTA PLUS REEX EN PESOS C', 'SUPER GESTION BRASIL REEXPRESADO EN $ C',
                      'SUPER BONOS INTERNACIONAL A', 'SUPERFONDO 2000', 'SUPERGESTION INT EUROPA C DOLARES',
                      'SUPERFONDO 2002', 'SUPERFONDO U$S PLUS', 'SUPER GESTION BRASIL', 'SUPERFONDO RENTA LATINOAMERICA', 'SUPERGESTION INTERNACIONAL A',
                      'SUPERFONDO LATINOAMERICA', 'SUPERFONDO ACCIONES BRASIL A', 'SUPERFONDO RENTA PLUS A', 'SUPERFONDO EUROPA', 'SUPERFONDO AMERICA',
                      'SUPERFONDO BRIC A', 'SUPER AHORRO U$S', 'SUPERFONDO AHORRO U$S', 'SUPERFONDO AHORRO U$S PLAZO FIJO', 'SUPERFONDO 2000 PLAZO FIJO',
                      'SUPERFONDO 2001', 'SUPER AHORRO U$S(EX LETES)', 'SUPERFONDO AHORRO U$S (EX LETES)', 'SUPERFONDO 2001 (EX LETES)']

  attr_reader :measured_at

  def initialize
    @doc = Nokogiri::HTML(open('http://www.santanderrio.com.ar/individuos/inversiones_fondos_rendimiento.jsp'))
    date_header_text = @doc.at_xpath('//table/tr/th').text
    date_text = /\d{2}\/\d{2}\/\d{4}/.match(date_header_text)[0]
    @measured_at = Time.parse(date_text)
  end

  def each_daily_deltas
    @doc.xpath('//div[@class="notaText"]/table/tr').each do |asset_row|
      row_childs = asset_row.children
      fund_name = row_childs[0].try(:text).try(:strip)
      if row_childs.count == 12 && !exclude?(fund_name)
        fund_daily_delta = parse_delta(row_childs[4].text.strip) 
        yield FundDelta.new(fund_name, fund_daily_delta)
      end
    end
  end

  private

  def exclude?(fund_name)
    (fund_name.nil? || FUNDS_TO_EXCLUDE.include?(fund_name))
  end

  def parse_delta(delta_as_string)
    delta_as_string.gsub(',', '.').gsub(')', '').gsub('(','-').to_f
  end
end
