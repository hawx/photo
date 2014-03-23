require 'exiftool'
require 'fileutils'
require 'RMagick'
require 'time'

class Photo
  include DataMapper::Resource

  property :id,           Serial
  property :title,        String
  property :description,  Text
  property :exif_json,    Text
  property :uploaded_at,  Time, default: -> (*) { Time.now }

  has 1, :original
  has 1, :large
  has 1, :small
  has 1, :thumb

  has n, :taggings
  has n, :tags, through: :taggings

  has n, :machine_taggings
  has n, :machine_tags, through: :machine_taggings

  def self.upload(temp_path, content_type)
    filename = SecureRandom.uuid
    path     = "public/uploads/#{filename}"
    img      = Magick::Image.read(temp_path).first

    original = Original.upload(temp_path, path, img, content_type)

    large    = Large.upload(nil, path, img, content_type)
    small    = Small.upload(nil, path, img, content_type)
    thumb    = Thumb.upload(nil, path, img, content_type)

    exif     = Exiftool.new(path)

    create exif_json: exif.to_display_hash.to_json,
           original: original,
           large: large,
           small: small,
           thumb: thumb
  end

  def title
    t = super
    (t.nil? || t.empty?) ? id : t
  end

  def url
    "/photos/#{id}"
  end

  def version(size)
    case size.to_sym
    when :original then original
    when :large    then large
    when :small    then small
    when :thumb    then thumb
    end
  end

  def tag_with(name)
    if MachineTag.is?(name)
      machine_tag = MachineTag.first_or_create(name: name)
      self.machine_tags << machine_tag
    else
      tag = Tag.first_or_create(name: name)
      self.tags << tag
    end
  end

  def tags
    ts = super
    ts.entries + machine_tags.entries
  end

  def date
    d = exif["Date Time Original"]
    d ? Time.strptime(d, "%Y:%m:%d %H:%M:%S") : NullTime
  end

  def exif
    JSON.parse(exif_json)
  end

  def prev
    Photo.last(:id.lt => self.id)
  end

  def next
    Photo.first(:id.gt => self.id)
  end
end
