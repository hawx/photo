class PhotoRepresenter < Roar::Decorator
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id, writeable: false
  property :title
  property :description
  property :url, writeable: false
  hash     :exif, writeable: false

  nested :sizes do
    property :large, decorator: SizeRepresenter, class: Size
    property :small, decorator: SizeRepresenter, class: Size
    property :thumb, decorator: SizeRepresenter, class: Size
  end

  collection :tags, decorator: TagRepresenter, class: Tag

  link :self do
    "/api/photos/#{represented.id}"
  end
end
