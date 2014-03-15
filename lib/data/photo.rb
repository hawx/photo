class Photo
  include DataMapper::Resource

  property :id,           Serial
  property :path,         String
  property :content_type, String
  property :description,  Text
  property :exif_json,    Text

  has n, :taggings
  has n, :tags, through: :taggings

  def self.upload(temp_path, content_type)
    filename = SecureRandom.uuid
    path = "public/uploads/#{filename}"
    FileUtils.cp(temp_path, path)

    exif = Exiftool.new(path)

    new(path: path,
        content_type: content_type,
        exif_json: exif.to_display_hash.to_json).save!
  end

  def url
    "/photos/#{id}"
  end

  def src_url
    "/upload/photos/#{id}"
  end

  def exif
    JSON.parse(exif_json)
  end

  def to_json
    {
      id: id,
      description: Markdown.render(description || '...'),
      sizes: {
        original: {
          url: src_url,
          content_type: content_type
        }
      },
      tags: tags.map {|t| {name: t.name, url: t.url} },
      exif: exif
    }.to_json
  end
end
