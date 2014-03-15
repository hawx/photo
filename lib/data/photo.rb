class Photo
  include DataMapper::Resource

  property :id,           Serial
  property :path,         String
  property :content_type, String
  property :description,  Text

  has n, :taggings
  has n, :tags, through: :taggings

  def self.upload(temp_path, content_type)
    filename = SecureRandom.uuid
    path = "public/uploads/#{filename}"
    FileUtils.cp(temp_path, path)

    new(path: path, content_type: content_type).save!
  end

  def url
    "/photos/#{id}"
  end

  def src_url
    "/upload/photos/#{id}"
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
      tags: tags.map {|t| {name: t.name, url: t.url} }
    }.to_json
  end
end
