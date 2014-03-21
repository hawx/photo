class PhotoVersion
  SIZES = {
    original: '-',
    large:    '1024x768',
    small:    '320x240',
    thumb:    '75x75'
  }

  include DataMapper::Resource

  property :id,   Serial
  property :size, Enum[:original, :large, :small, :thumb]
  property :path, String
  property :type, String

  belongs_to :photo

  def url
    "/image/#{id}"
  end
end

class Photo
  include DataMapper::Resource

  property :id,           Serial
  property :title,        String
  property :description,  Text
  property :exif_json,    Text

  has n, :photo_versions

  has n, :taggings
  has n, :tags, through: :taggings

  def self.upload(temp_path, content_type)
    format = case content_type
             when 'image/jpeg' then 'JPG'
             when 'image/png' then 'PNG'
             else puts content_type
             end

    versions = []

    filename = SecureRandom.uuid
    path = "public/uploads/#{filename}"
    FileUtils.cp(temp_path, path)
    versions << PhotoVersion.create(size: :original, path: path, type: content_type)

    img = Magick::Image.read(path) {|i| i.format = format }.first
    versions << save_version(path, img, :large)
    versions << save_version(path, img, :small)
    versions << save_version(path, img, :thumb)

    exif = Exiftool.new(path)

    new(exif_json: exif.to_display_hash.to_json,
        photo_versions: versions).save!
  end

  def self.save_version(path, img, size)
    file_path = "#{path}_#{size}.jpg"
    img.change_geometry(PhotoVersion::SIZES[size]) {|cols, rows, img|
      img.resize!(cols, rows)
    }.write(file_path)

    PhotoVersion.create(size: size, path: file_path, type: 'image/jpeg')
  end

  def url
    "/photos/#{id}"
  end

  def original
    photo_versions.first(:size => :original)
  end

  def large
    photo_versions.first(:size => :large)
  end

  def small
    photo_versions.first(:size => :small)
  end

  def thumb
    photo_versions.first(:size => :thumb)
  end

  def date
    d = exif["Date Time Original"]
    d ? Time.strptime(d, "%Y:%m:%d %H:%M:%S") : NullTime
  end

  def exif
    JSON.parse(exif_json)
  end

  def to_json
    {
      id: id,
      title: title,
      description: Markdown.render(description || '...'),
      sizes: {
        original: {
          url: original.url,
          content_type: original.type
        },
        large: {
          url: large.url,
          content_type: large.type
        },
        small: {
          url: small.url,
          content_type: small.type
        },
        thumb: {
          url: thumb.url,
          content_type: thumb.type
        }
      },
      tags: tags.map {|t| {name: t.name, url: t.url} },
      exif: exif
    }.to_json
  end
end
