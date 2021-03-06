require 'sinatra/base'
require 'slim'
require 'sass'

require_relative 'lib/markdown'
require_relative 'lib/time'
require_relative 'lib/data'

class Web < Sinatra::Base
  PAGE_SIZE = 10

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
    slim :photo, locals: {photo: Photo.get(id.to_i)}
  end

  get '/photos/:id/sizes/:size' do |id, size|
    photo = Photo.get(id.to_i)
    version = photo.version(size)

    slim :photo_size, locals: {photo: photo, size: size}
  end

  get '/image/:id' do |id|
    version = Size.get(id.to_i)

    content_type version.mime
    send_file version.path
  end

  get '/tags' do
    slim :tags, locals: {grouped_tags: Tags.grouped}
  end

  get '/tags/:name' do |name|
    page = params['page'] || 1

    tag = Tag.first(safe_name: name) || MachineTag.first(name: name)
    return 404 unless tag

    photos = tag.photos.page(page, per_page: PAGE_SIZE)
    slim :tag, locals: {tag: tag, photos: photos}
  end

  get '/styles.css' do
    sass 'styles/main'.to_sym
  end
end
