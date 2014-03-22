class Tag
  include DataMapper::Resource

  property :id,   Serial
  property :name, String

  has n, :taggings
  has n, :photos, through: :taggings

  def url
    "/tags/#{id}"
  end

  def self.grouped
    all
      .group_by {|t| t.name[0] }
      .sort_by {|k,v| k }
      .select {|k,v| [k, v.sort_by(&:name)] }
  end

  def to_json(opts={})
    {
      id: id,
      name: name
    }.to_json
  end
end
