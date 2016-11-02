
enable :sessions
set :session_secret, $os_env[:sessions]

before do
  headers "Content-Type" => "text/html; charset=utf-8"
  @logins = $config.admin_users
end

get '/' do
  @title = 'The Video Store'
  @message = params[:mess] || 'Welcome To The Video Store!'
  haml :index
end

get '/video/list' do
  @title = 'Available Videos'
  @videos = Video.all(:order => [:created_at.desc])
  haml :list
end

get '/video/new' do
  process_request request, 'upload_video' do |req, username|
    @title = 'Upload Video'
    haml :new
  end
end

post '/video/create' do  
  video = create_video(params[:video])
  if video.save
    @message = 'Video was saved.'
  else
    @message = 'Video was not saved.'
  end
  @videos = Video.all(:order => [:created_at.desc])

  haml :list
end

get '/video/delete/:id' do
  process_request request, 'delete_video' do |req, username|
    video = Video.get params[:id]
    video.attachments.each do |att|
      File.delete(Base64.urlsafe_decode64(att[:path]))
      File.delete(Base64.urlsafe_decode64(att[:link_path]))
    end
    video.attachments.destroy
    video.destroy
    redirect '/'
  end
end

get '/video/watch/:id' do
  #process_request request, 'watch_video' do |req, username|
    video = Video.get(params[:id])
    if video
      @videos = {}
      video.attachments.each do |attachment|
        supported_mime_type = $config.supported_mime_types.select { |type| type['extension'] == attachment.extension }.first
        if supported_mime_type['type'] === 'video'
          @videos[attachment.id] = { :path => File.join($config.file_properties.video.link_path['public'.length..-1], attachment.filename) }
        end
      end
      if @videos.empty?
        redirect "/video/list"
      else
        @title = "Watch #{video.title}"
        haml :watch
      end
    else
      redirect '/video/list'
    end
  #end
end

get '/media/video/:video_url' do
  video_name = Base64.urlsafe_decode64("#{params[:video_url]}")
  path = "#{$os_env[:home]}/public/media/video/#{video_name}"
  f = File.open(path, "r").read
end

get '/download/media/video/:video_url' do
  video_name = Base64.urlsafe_decode64("#{params[:video_url]}")
  f = File.open(video_name, "r").read
end

get '/login' do
  @mess = params[:mess] if params[:mess]
  haml :login
end

post '/login' do
  username = h(params[:username])
  password = Digest::SHA256.hexdigest(h(params[:password]))

  if @logins[username] && @logins[username] == password
    session[:token] = token(username)
    redirect '/'
  else
    redirect '/login?mess=Unauthorized.'
  end
end

get '/logout' do
  session[:token] = nil
  redirect '/?mess=Bye.'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def token username
    JWT.encode payload(username), $os_env[:jwt_sec], 'HS256'
  end

  def payload username
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: $os_env[:jwt_iss],
      scopes: ['watch_video', 'upload_video', 'delete_video'],
      user: {
        username: username
      }
    }
  end

  def process_request req, scope
    begin
      options = { algorithm: 'HS256', iss: $os_env[:jwt_iss] }
      payload, header = JWT.decode session[:token], $os_env[:jwt_sec], true, options

      scopes, user = payload['scopes'], payload['user']
      username = user['username'].to_sym

      if @logins[username] && scopes.include?(scope)
        yield req, username
      else
        redirect '/login'
      end

    rescue 
      redirect '/login?mess=Sorry, unauthorized :('
    end
  end

  def create_video(video)
    
    new_video = Video.new(
      :title => h(video[:title]),
      :length => 240
    )
    video_attachment = new_video.attachments.new
    video_attachment.handle_upload(params['video-file'])

    new_video
  end

end

