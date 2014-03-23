class SizeRepresenter < Roar::Decorator
  include Roar::Representer::JSON

  property :id
  property :url
  property :height
  property :width
  property :mime, as: :content_type
end
