module Sinatra
  module Routes

    class VideoController < AppController

      get '/video/list' do
        @title = 'Available Videos'
        @videos = Video.all
        haml :list
      end

      get '/video/like/:id' do
        process_request request, 'like_video' do |req, username|
          video = Video.get(params[:id])
          if video
            video. likes += 1
            if video.save
              flash[:success] = "Liked! Nice:)"
            else
              flash[:error] = "Sorry Error Occurred."
            end
            redirect "/video/list"
          else
            flash[:warning] = "No such video("
            redirect '/video/list'
          end
        end
      end

    end
  end
end