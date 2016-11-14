module Sinatra
  module Routes
    
    class General < AppController
      get '/' do
        @videos = Video.all.count
        @users = User.all.count
        
        haml :index, :layout => false
      end

      get '/about' do
        haml :about
      end

      post '/search/:search' do
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

    end
  end
end