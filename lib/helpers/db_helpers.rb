module DB_helpers

  def create_video(username, video)
    user = User.first(:login => username)
    new_video = user.videos.new(
          :title => h(video[:title]),
          :watch_count => 0,
          :likes => 0
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
