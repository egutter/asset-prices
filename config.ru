require 'bundler/setup'
Bundler.require(:default)

require File.dirname(__FILE__) + "/app/asset_prices.rb"

run AssetPrices
