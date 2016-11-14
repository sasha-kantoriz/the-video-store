module Sinatra
  module Routes

    class UserController < AppController
      get '/user/home' do
        if session[:username].nil? || session[:username].empty? || session[:token].nil?
          flash[:info] = 'Sign in or register.'
          redirect '/login'
        end
        @user = User.first(:login => session[:username])
        @videos = @user.videos
        haml :user_home
      end

    end
  end
end