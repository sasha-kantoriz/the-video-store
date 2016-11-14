module Sinatra
  module Routes

    class VideoProcessing < AppController

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
        video = Video.get(params[:id])
        if video
          @videos = {}
          video.attachments.each do |attachment|
            supported_mime_type = Config::CONFIG['supported_mime_types'].select { |type| 
              type['extension'] == attachment.extension 
            }.first
            if supported_mime_type['type'] === 'video'
              @videos[attachment.id] = { 
                :path => File.join(
                  Config::CONFIG['file_properties']['video']['link_path']['public'.length..-1], 
                  attachment.filename
                ) 
              }
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
      end

      get '/media/video/:video_url' do
        video_name = Base64.urlsafe_decode64("#{params[:video_url]}")
        path = "#{Config::OS_ENV[:home]}/public/media/video/#{video_name}"
        # f = File.open(path, "r").read
        send_file path
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