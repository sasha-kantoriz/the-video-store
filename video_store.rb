
enable :sessions
set :session_secret, $os_env[:sessions]

before do
  headers "Content-Type" => "text/html; charset=utf-8"
end


get '/' do
  @videos = Video.all.count
  @users = User.all.count
  
  haml :index, :layout => false
end

get '/video/list' do
  @title = 'Available Videos'
  @videos = Video.all(:order => [:created_at.desc])
  haml :list
end

post '/video/create' do
  user_new_video = create_video(session[:username], params[:video])
  if user_new_video.save
    flash[:success] = 'Video was saved.'
  else
    flash[:error] = 'Video was not saved.'
  end

  redirect '/user/home'
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
    flash[:info] = "Video was deleted."
    redirect '/user/home'
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
        flash[:warning] = "No such video("
        redirect "/video/list"
      else
        video.watch_count += 1
        video.save
        @title = video.title
        haml :watch
      end
    else
      flash[:warning] = "No such video("
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
  process_request request, 'download_video' do |req, username|
    video_name = Base64.urlsafe_decode64("#{params[:video_url]}")
    # f = File.open(video_name, "r").read
    send_file video_name
  end
end

get '/user/home' do
  if session[:username].nil? || session[:username].empty? || session[:token].nil?
    flash[:info] = 'Sign in or register.'
    redirect '/login'
  end
  @user = User.first(:login => session[:username])
  @videos = @user.videos
  haml :user_home
end

post '/search' do
  @videos = Video.all.select { |v|
    v.title.include? params[:search]
  }
  if @videos.empty?
    flash[:warning] = "No matching results for #{params[:search]}."
    redirect '/video/list'
  else
    haml :list
  end
end

get '/login' do
  haml :login
end

post '/signin' do
  user = User.first(:login => h(params[:username]))
  pass = h(params[:password])
  if user && user.auth(pass)
    flash[:success] = "Welcome, #{user.login}!"
    session[:token] = token(user.login)
    session[:username] = user.login
    redirect '/user/home'
  else
    flash[:error] = "Sorry, unauthorized :("
    redirect '/login'
  end
end

post '/signup' do
  user, error = create_user(params[:user])
  if user && user.save
    flash[:success] = "Welcome, #{user.login}!"
    session[:token] = token(user.login)
    session[:username] = user.login
    redirect '/user/home'
  else 
    flash[:error] = error
    redirect '/login'
  end
end

get '/logout' do
  session.clear
  flash[:info] = "Bye."
  redirect '/'
end

get '/about' do
	haml :about
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def token(username, scopes=['upload_video', 'download_video', 'delete_video'])
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
      username = user['username']

      if scopes.include?(scope)
        yield req, username
      else
        flash[:warning] = "Not Available."
        redirect '/login'
      end

    rescue
      flash[:error] = 'Sorry, unauthorized :('
      redirect '/login'
    end
  end

  def create_video(username, video)
    user = User.first(:login => username)
    new_video = user.videos.new(
      :title => h(video[:title]),
      :watch_count => 0
    )
    video_attachment = new_video.attachments.new
    video_attachment.handle_upload(params['video-file'])

    user
  end

  def create_user(user)
    error = ''
    if User.all(:login => h(user[:login])).count > 0
      return nil, "This login is taken!"
    elsif User.all(:email => h(user[:email])).count > 0
      return nil, "Need unique email!"
    elsif (h(user[:login]).length < 1) || (h(user[:email]).length < 1)
      return nil, "Empty fields!"  
    elsif h(user[:pass]).length < 6
      return nil, "Too short password!"
    elsif h(user[:pass]) != h(user[:conf_pass])
      return nil, "Password not confirmed!"  
    end
    new_user = User.new(
      :login => h(user[:login]),
      :email => h(user[:email]),
      :pass => h(user[:pass])
    )
    return new_user, error
  end

end

