module Sinatra
  module Routes
    
    class Login < AppController

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

    end
  end
end