class Market

  def initialize(assets, index)
    @index, @assets = index, assets
  end

  def starts_at
    @assets.first.series_start_date
  end

  def assets_with_index
    @assets.collect {|asset| AssetWithIndex.new asset, @index}.clone << @index
  end

  def days
    @index.days
  end

  class AssetWithIndex
    def initialize(asset, index)
      @asset, @index = asset, index
    end

    def beta
      @asset.beta(@index)
    end

    def method_missing(method, *args, &block)
      @asset.send method, *args, &block
    end
  end
end