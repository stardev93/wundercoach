# Does not compress assets marked with "no_asset_compression"
# use this to avoid compression, e.g. on an already compressed file
class SelectiveAssetsCompressor < Uglifier
  def initialize(options = {})
    options.merge(comments: :all)
    super(options)
  end

  def compress(string)
    if string =~ /no_asset_compression/
      string
    else
      super(string)
    end
  end
end
