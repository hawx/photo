require 'sinatra/base'
require 'sinatra/json'

require_relative 'lib/data'
require_relative 'lib/representers'

class Api < Sinatra::Base
  helpers Sinatra::JSON

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
