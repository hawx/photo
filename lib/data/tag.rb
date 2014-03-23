module Tags
  def self.grouped
    (Tag.all.entries + MachineTag.all.entries)
      .group_by {|t| t.name[0] }
      .sort_by {|k,v| k }
      .map {|k,v| [k, v.sort_by(&:name)] }
  end
end

class Tag
  include DataMapper::Resource

  property :id,        Serial
  property :name,      String
  property :safe_name, String

  has n, :taggings
  has n, :photos, through: :taggings

  before :save do |tag|
    tag.safe_name = tag.name.gsub(/\s+/, '')
  end

  def url
    "/tags/#{safe_name}"
  end

  def self.grouped
    all
      .group_by {|t| t.name[0] }
      .sort_by {|k,v| k }
      .select {|k,v| [k, v.sort_by(&:name)] }
  end
end

class MachineTag
  MATCH = /(\w+):(\w+)=(.+)/
  include DataMapper::Resource

  property :id,        Serial
  property :name,      String
  property :namespace, String
  property :predicate, String
  property :value,     String

  has n, :machine_taggings
  has n, :photos, through: :machine_taggings

  before :save do |tag|
    tag.namespace, tag.predicate, tag.value = tag.name.scan(MATCH).first
  end

  alias_method :safe_name, :name

  def url
    "/tags/#{name}"
  end

  def self.is?(str)
    str.scan(MATCH).any?
  end

  def self.parts(str)
    str.scan(MATCH).first
  end
end
