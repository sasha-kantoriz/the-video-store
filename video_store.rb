
enable :sessions
set :session_secret, $os_env[:sessions]

before do
  headers "Content-Type" => "text/html; charset=utf-8"
end


get '/' do
  @title = 'The Video Store'
  @videos = Video.all.count
  @users = User.all.count
  
  haml :index, :layout => false
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
  process_request request, 'watch_video' do |req, username|
    video_name = Base64.urlsafe_decode64("#{params[:video_url]}")
    f = File.open(video_name, "r").read
  end
end

get '/login' do

  haml :login
end

post '/signin' do
  user = User.get(h(params[:username]))
  pass = h(params[:password])

  if user && user.auth(pass)
    session[:token] = token(user.login)
    session[:username] = user.login
    @message = "Welcome, #{user.login}!"
    redirect '/'
  else
    @message = "Sorry, unauthorized :("
    redirect '/login'
  end
end

post '/signup' do
  login = h(params[:user[:login]])
  email = h(params[:user[:email]])
  password = h(params[:user[:password]])

  puts params

end

get '/logout' do
  session.clear
  @message = "Bye."
  redirect '/'
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def token(username, scopes=['watch_video', 'upload_video'])
    JWT.encode payload(username, scopes), $os_env[:jwt_sec], 'HS256'
  end

  def payload(username, scopes)
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: $os_env[:jwt_iss],
      scopes: scopes,
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
        @message = "Not Available"
        redirect '/login'
      end

    rescue
      @message = 'Sorry, unauthorized :('
      redirect '/login'
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

  def create_user(user)
    new_user = User.new(
      :login => h(user[:login]),
      :email => h(user[:email]),
      :pass => h(user[:pass])
    )

    new_user
  end

end

