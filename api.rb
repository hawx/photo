require 'roar/decorator'
require 'roar/representer/json'
require 'sinatra/base'
require 'sinatra/json'

require_relative 'lib/data'

class SizeRepresenter < Roar::Decorator
  include Roar::Representer::JSON

  property :id
  property :url
  property :height
  property :width
  property :mime, as: :content_type
end

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

class Api < Sinatra::Base
  helpers Sinatra::JSON

  helpers do
    def json_body
      JSON.parse(request.body.read)
    end
  end

  patch '/tags/:id' do |id|
    tag = Tag.get(id.to_i)
    TagRepresenter.new(tag).from_json(request.body.read)
    tag.save!

    json TagRepresenter.new tag
  end

  get '/photos/:id' do |id|
    json PhotoRepresenter.new Photo.get(id.to_i)
  end

  patch '/photos/:id' do |id|
    photo = Photo.get(id.to_i)
    PhotoRepresenter.new(photo).from_json(request.body.read)
    photo.save!

    json PhotoRepresenter.new photo
  end

  post '/photos/:id/tags' do |id|
    name = JSON[request.body.read]['name']
    return 400 unless name

    photo = Photo.get(id.to_i)
    tag = Tag.first_or_create(name: name)
    photo.tags << tag
    photo.save!

    json PhotoRepresenter.new photo
  end

  delete '/photos/:id/tags/:tag_id' do |id, tag_id|
    tagging = Tagging.first(photo_id: id.to_i, tag_id: tag_id.to_i)
    tagging.destroy!

    json PhotoRepresenter.new Photo.get(id.to_i)
  end
end
