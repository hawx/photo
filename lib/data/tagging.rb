class Tagging
  include DataMapper::Resource

  belongs_to :tag,   key: true
  belongs_to :photo, key: true
end
