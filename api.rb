require 'json'
require 'sinatra/base'
require 'sinatra/json'

require_relative 'lib/data'

class Api < Sinatra::Base
  helpers Sinatra::JSON

  patch '/tags/:id' do |id|
    tag = Tag.get(id.to_i)
    tag.update(JSON.parse(request.body.read))
    tag.save!

    json tag
  end

  get '/photos/:id' do |id|
    json Photo.get(id.to_i)
  end

  patch '/photos/:id' do |id|
    photo = Photo.get(id.to_i)
    photo.update(JSON.parse(request.body.read))
    photo.save!

    json photo
  end

  post '/photos/:id/tags' do |id|
    photo = Photo.get(id.to_i)
    tag = Tag.first_or_create(JSON.parse(request.body.read))
    photo.tags << tag
    photo.save!

    json photo
  end

  delete '/photos/:id/tags/:tag_id' do |id, tag_id|
    tagging = Tagging.first(photo_id: id.to_i, tag_id: tag_id.to_i)
    tagging.destroy!

    json Photo.get(id.to_i)
  end
end
