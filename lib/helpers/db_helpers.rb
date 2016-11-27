module DB_helpers

  def create_video(username, video)
    user = User.first(:login => username)
    new_video = user.add_video(
          :title => h(video[:title]),
          :watch_count => 0,
          :likes => 0,
          :created_at => Time.now,
          :video => File.open(video[:file][:tempfile])
    )
    
    new_video
  end

  def create_user(user)
    error = ''
    login_exist = User.find(:login => h(user[:login]))
    email_exist = User.find(:email => h(user[:email]))

    if !login_exist.nil? 
      return nil, "This login is taken!"
    elsif !email_exist.nil?
      return nil, "Need unique email!"
    elsif (h(user[:login]).length < 1) || (h(user[:email]).length < 5)
      return nil, "Empty fields!"  
    elsif h(user[:pass]).length < 6
      return nil, "Too short password!"
    elsif h(user[:pass]) != h(user[:conf_pass])
      return nil, "Password not confirmed!"  
    end
    new_user = User.create(
          :login => h(user[:login]),
          :email => h(user[:email]),
          :pass => h(user[:pass])
    )
    return new_user, error
  end
end
