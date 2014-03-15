class Tag
  include DataMapper::Resource

  property :id,   Serial
  property :name, String

  has n, :taggings
  has n, :photos, through: :taggings

  def url
    "/tags/#{id}"
  end
end
