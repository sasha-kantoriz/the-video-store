class User
  include DataMapper::Resource

  has n, :videos

  property :id,           Serial
  property :login,        String
  property :pass,         BCryptHash
  property :email,        String

  property :created_at,   DateTime

  def auth(attempted_password)
    self.pass == attempted_password
  end

end

class Video
  include DataMapper::Resource

  belongs_to :user
  has n, :attachments

  property :id,           Serial
  property :created_at,   DateTime
  property :watch_count,  Integer
  property :likes,        Integer

  property :title,        String
  property :updated_at,   DateTime
end

class Attachment
  include DataMapper::Resource

  belongs_to :video

  property :id,           Serial
  property :created_at,   DateTime
  property :extension,    String
  property :filename,     Text
  property :mime_type,    String
  property :path,         Text
  property :link_path,    Text
  property :size,         Integer
  property :updated_at,   DateTime

  def handle_upload(file)
    self.extension = File.extname(file[:filename]).sub(/^\./, '').downcase
    supported_mime_type = Config::CONFIG['supported_mime_types'].select { |type| type['extension'] == self.extension }.first
    return false unless supported_mime_type

    abs_path = File.join(Dir.pwd, Config::CONFIG['file_properties']['video']['absolute_path'], file[:filename])
    link_path = File.join(Dir.pwd, Config::CONFIG['file_properties']['video']['link_path'], file[:filename])

    self.mime_type = file[:type]
    self.size      = File.size(file[:tempfile])
    self.filename  = Base64.urlsafe_encode64(file[:filename])
    self.path      = Base64.urlsafe_encode64(abs_path)    
    self.link_path = Base64.urlsafe_encode64(link_path)

    safe_upload(abs_path, link_path, file[:tempfile], file[:filename])
  end

  def safe_upload(abs_path, link_path, tempfile, filename)
    if File.exist?(abs_path) || File.exist?(link_path)
      timestamp = Time.now.strftime('%y_%h_%d_%H-%M-%S__')
      filename = timestamp + filename
      abs_path = File.join(File.dirname(abs_path), filename)
      link_path = File.join(File.dirname(link_path), filename)
    end

    File.open(abs_path, 'wb') do |f|
      f.write(tempfile.read)
    end

    FileUtils.symlink(abs_path, link_path)
  end
end
