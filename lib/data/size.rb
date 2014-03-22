class Size
  include DataMapper::Resource

  property :id,     Serial
  property :height, Integer
  property :width,  Integer
  property :path,   String
  property :mime,   String

  property :type,   Discriminator

  belongs_to :photo

  def url
    "/image/#{id}"
  end
end

class Original < Size
  def self.upload(temp_path, upload_path, img, content_type)
    FileUtils.cp(temp_path, upload_path)

    create height: img.rows,
           width: img.columns,
           path: upload_path,
           mime: content_type
  end
end

class Large < Size
  BOUNDS = '1024x768'

  def self.upload(temp_path, upload_path, img, content_type)
    file_path = "#{upload_path}_large.jpg"

    resized = img.change_geometry(BOUNDS) do |cols, rows, image|
      image.resize! cols, rows
    end
    resized.write('jpeg:' + file_path)

    create height: resized.rows,
           width: resized.columns,
           path: file_path,
           mime: 'image/jpeg'
  end
end

class Small < Size
  BOUNDS = '320x240'

  def self.upload(temp_path, upload_path, img, content_type)
    file_path = "#{upload_path}_small.jpg"

    resized = img.change_geometry(BOUNDS) do |cols, rows, image|
      image.resize! cols, rows
    end
    resized.write('jpeg:' + file_path)

    create height: resized.rows,
           width: resized.columns,
           path: file_path,
           mime: 'image/jpeg'
  end
end

class Thumb < Size
  BOUNDS = '75x75'

  def self.upload(temp_path, upload_path, img, content_type)
    file_path = "#{upload_path}_thumb.jpg"

    resized = img.resize_to_fill(75)
    resized.write('jpeg:' + file_path)

    create height: resized.rows,
           width: resized.columns,
           path: file_path,
           mime: 'image/jpeg'
  end
end
