module Sinatra
  module Routes

    class VideoProcessing < AppController

      #@uploader = VideoUploader.new

      post '/video/create' do
        process_request request, 'upload_video' do |req, username|
          user_new_video = create_video(session[:username], params[:video])
          if user_new_video.save
            flash[:success] = 'Video was saved.'
          else
            flash[:error] = 'Video was not saved.'
          end

          redirect '/user/home'
        end
      end

      get '/video/delete/:id' do
        process_request request, 'delete_video' do |req, username|
          video = Video[params[:id]]
          video.destroy
          flash[:info] = "Video was deleted."
          redirect '/user/home'
        end
      end

      get '/video/watch/:id' do
        @video = Video[params[:id]]
        if @video
          @video_data = JSON.parse @video.video_data

          @title = @video.title
          haml :watch          
        else
          flash[:warning] = "No such video("
          redirect '/video/list'
        end
      end

      get '/video/show/:video_url' do
        # video_name = Base64.urlsafe_decode64("#{params[:video_url]}")
        # f = File.open(path, "r").read
        path = "#{Config::OS_ENV[:home]}/public/uploads/cache/#{params[:video_url]}"
        send_file path, :disposition => 'inline', :buffer_size => (1024 * 4 * 4)
      end

      get '/download/media/video/:video_url' do
        process_request request, 'download_video' do |req, username|
          video_name = Base64.urlsafe_decode64("#{params[:video_url]}")
          # f = File.open(video_name, "r").read
          send_file video_name
        end
      end

    end
  end
end