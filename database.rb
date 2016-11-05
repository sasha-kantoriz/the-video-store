
configure do
  File.open("#{$os_env[:home]}/../logs/data_mapper.log", "a") {|log| log.puts "=" * 40; log.puts Time.now}
  DataMapper::Logger.new("#{$os_env[:home]}/../logs/data_mapper.log")
  DataMapper::setup(:default, File.join('sqlite3://', Dir.pwd, '../db/development.db'))
end

class User
  include DataMapper::Resource

  has n, :videos

  property :id,           Serial
  property :login,        String
  property :pass,         BCryptHash
  property :email,        Text

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
  property :length,       Integer
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
    supported_mime_type = $config.supported_mime_types.select { |type| type['extension'] == self.extension }.first
    return false unless supported_mime_type

    abs_path = File.join(Dir.pwd, $config.file_properties.video.absolute_path, file[:filename])
    link_path = File.join(Dir.pwd, $config.file_properties.video.link_path, file[:filename])

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

configure :development do
  DataMapper.finalize
  DataMapper.auto_upgrade!
end
