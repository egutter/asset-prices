require_relative "./models/daily_return"
require_relative "./models/daily_return_series"
require_relative "./models/asset"
require_relative "./models/market"
require_relative "./stats_calculators/stats_calculator"
require_relative "./stats_calculators/tempo_db_stats_calculator"
require_relative "./builders/tempo_db_market_index_builder"
require_relative "./reports/stats_report"
require_relative "./adapters/tempo_db_daily_return_adapter"
require_relative "./repositories/tempo_db_repository"
require_relative "./repositories/yahoo_finance_repository"

class AssetPrices < Sinatra::Base
  configure :development do
    ENV['TEMPODB_API_HOST']= 'api.tempo-db.com'
    ENV['TEMPODB_API_KEY']= '4e1f2d7394f54886b2f7b7a10e6647b6'
    ENV['TEMPODB_API_PORT']= '443'
    ENV['TEMPODB_API_SECRET']= '979fd9f0fac942d5868c2accd2772b2c'
    ENV['TEMPODB_API_SECURE']= 'True'
  end

  set :public_folder, File.dirname(__FILE__) + '/assets'

  register Sinatra::Session
  register Gon::Sinatra
  register Sinatra::Numeric

  use OmniAuth::Builder do
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  end

  set :session_fail, '/login'
  set :session_secret, 'JMNeYQVPYtUpLU62kwpwnvLC!KqQuB5gUQDmRKnLrRw7kr4vE'

  %w(get post).each do |method|
    send(method, "/auth/:provider/callback") do
      session_start!
      @user = request.env['omniauth.auth'].info.to_json
      session['access_token'] = session['oauth'].get_access_token(params[:code])
      env['omniauth.auth'] # => OmniAuth::AuthHash
    end
  end

  get '/' do
    #session!
    @selected_assets = []
    from_date = Time.now - (60 * 60 * 24 * 365)
    build_report(from_date, Asset.all_indexes)
    haml :index
  end

  get '/login' do
    if session?
      redirect '/'
    else
      '<form method="POST" action="/auth/github">' +
      '<input type="submit" value="Sign with Github">' +
      '</form>'
    end
  end

  get '/logout' do
    session_end!
    redirect '/'
  end

  post '/filter' do
    from_date = Time.now - (60 * 60 * 24 * 365)
    @selected_assets = params[:filter_by_asset_names] || []
    @selected_assets.concat Asset.santander_fund_symbols if params[:include_all_funds]
    @selected_assets.concat Asset.merval_stock_symbols if params[:include_all_stocks]

    from_date = Time.now - (60 * 60 * 24 * 365)
    build_report(from_date, @selected_assets.clone.concat(Asset.all_indexes))
    haml :index
  end

  def build_report(from_date, include_asset_names)
    @funds = TempoDbRepository.new().all_funds_from(from_date)
    fund_market = Market.new(@funds, TempoDbMarketIndexBuilder.build(@funds))
    stock_symbols = Asset.merval_stock_symbols.select {|symbol| include_asset_names.include?(symbol) }
    merval_index = yahoo_repository.merval_index(fund_market.starts_at)
    stock_market = Market.new(yahoo_repository.all_daily_returns_from(fund_market.starts_at, stock_symbols, merval_index), merval_index)
    @stats_report = StatsReport.new(fund_market, stock_market).add_filter_by_names(include_asset_names)
    gon.daily_return_dates = @stats_report.days
    gon.dates_step = @stats_report.dates_step
    gon.daily_return_series = @stats_report.daily_returns_to_json
    gon.cumulative_daily_return_series = @stats_report.cumulative_daily_returns_to_json
  end

  def yahoo_repository
    YahooFinanceRepository.new()
  end
end