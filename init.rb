Bundler.require

require 'yaml'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/sequel'
require 'shrine/storage/file_system'

require './config/config_reader'

require './lib/controllers/video_uploader'
require './lib/models/db'

require './lib/helpers/security_helpers'
require './lib/helpers/db_helpers'

require './lib/controllers/app_controller'

require './lib/routes/login'
require './lib/routes/general'
require './lib/routes/user_controller'
require './lib/routes/video_controller'
require './lib/routes/video_processing'
require './lib/main'


class PromoteJob
  include Sidekiq::Worker
  def perform(data)
    Shrine::Attacher.promote(data)
  end
end

class DeleteJob
  include Sidekiq::Worker
  def perform(data)
    Shrine::Attacher.delete(data)
  end
end


Shrine.plugin :sequel
Shrine.plugin :cached_attachment_data # for forms
Shrine.plugin :rack_file # for non-Rails apps
Shrine.plugin :backgrounding
Shrine::Attacher.promote { |data| PromoteJob.perform_async(data) }
Shrine::Attacher.delete { |data| DeleteJob.perform_async(data) }

VideoUploader.storages = {
  :cache => Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary
  :store => Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"), # permanent
}
