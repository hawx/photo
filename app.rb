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

PAGE_SIZE = 10

helpers do
  def accept!(type)
    pass unless request.accept.empty? || request.preferred_type.include?(type)
  end
end

get '/' do
  page = params['page'] || 1

  slim :photos, locals: {photos: Photo.page(page, per_page: PAGE_SIZE)}
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

get '/photos/:id/sizes/:size' do |id, size|
  accept! 'text/html'

  photo = Photo.get(id.to_i)
  version = photo.version(size)
  slim :photo_size, locals: {photo: photo, size: size}
end

get '/image/:id' do |id|
  version = PhotoVersion.get(id.to_i)

  content_type version.type
  send_file version.path
end

get '/tags' do
  accept! 'text/html'
  slim :tags, locals: {grouped_tags: Tag.grouped}
end

get '/tags/:id' do |id|
  accept! 'text/html'

  page = params['page'] || 1

  tag = Tag.get(id.to_i)
  photos = tag.photos.page(page, per_page: PAGE_SIZE)
  slim :tag, locals: {tag: tag, photos: photos}
end

get '/photos/:id', :provides => :json  do |id|
  Photo.get(id.to_i).to_json
end

patch '/photos/:id', :provides => :json do |id|
  photo = Photo.get(id.to_i)
  photo.update(JSON.parse(request.body.read))
  photo.save!

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
