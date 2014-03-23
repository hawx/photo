class TagRepresenter < Roar::Decorator
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id, writeable: false
  property :name
  property :url, writeable: false

  link :self do
    "/api/tags/#{represented.id}"
  end
end
