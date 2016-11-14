Bundler.require

require 'sinatra/base'
require 'sinatra/flash'

require './config/config_reader'
require './lib/models/database'
require './lib/helpers/db_helpers'
require './lib/helpers/security_helpers'

require './lib/controllers/app_controller'
require './lib/routes/login'
require './lib/routes/general'
require './lib/routes/user_controller'
require './lib/routes/video_controller'
require './lib/routes/video_processing'
require './lib/main'

App.configure do
  File.open("#{Config::OS_ENV[:home]}/../logs/data_mapper.log", "a") {|log| log.puts "=" * 40; log.puts Time.now}
  DataMapper::Logger.new("#{Config::OS_ENV[:home]}/../logs/data_mapper.log")
  DataMapper::setup(:default, File.join('sqlite3://', Config::OS_ENV[:home], '../db/development.db'))

  DataMapper.finalize
  DataMapper.auto_upgrade!
end

run App
