require 'exiftool'
require 'fileutils'
require 'json'
require 'RMagick'
require 'sinatra'
require 'slim'
require 'time'

require_relative 'lib/markdown'
require_relative 'lib/time'
require_relative 'lib/data'

helpers do
  def accept!(type)
    pass unless request.accept.empty? || request.preferred_type.include?(type)
  end
end

get '/' do
  slim :photos, locals: {photos: Photo.all}
end

get '/upload' do
  slim :upload
end

post '/upload' do
  Photo.upload(params[:file][:tempfile].path, params[:file][:type])
  redirect '/'
end

get '/photos/:id' do |id|
  accept! 'text/html'
  slim :photo, locals: {photo: Photo.get(id.to_i)}
end

get '/tags' do
  accept! 'text/html'
  slim :tags, locals: {grouped_tags: Tag.grouped}
end

get '/tags/:id' do |id|
  accept! 'text/html'
  slim :tag, locals: {tag: Tag.get(id.to_i)}
end

get '/photos/:id', :provides => :json  do |id|
  Photo.get(id.to_i).to_json
end

patch '/photos/:id', :provides => :json do |id|
  photo = Photo.get(id.to_i)
  photo.update(JSON.parse(request.body.read))
  photo.save!

  content_type 'application/json'
  photo.to_json
end

post '/photos/:id/tags', :provides => :json do |id|
  photo = Photo.get(id.to_i)
  tag = Tag.first_or_create(JSON.parse(request.body.read))
  photo.tags << tag
  photo.save!

  photo.to_json
end

delete '/photos/:id/tags/:tag_id', :provides => :json do |id, tag_id|
  tagging = Tagging.first(photo_id: id.to_i, tag_id: tag_id.to_i)
  tagging.destroy!

  Photo.get(id.to_i).to_json
end

get '/image/:id' do |id|
  version = PhotoVersion.get(id.to_i)

  content_type version.type
  send_file version.path
end
