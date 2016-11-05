Bundler.require
require 'dm-migrations'

require './config/config_reader'
require './database'

require './video_store'

set :environment, :development
set :run, false
set :raise_errors, true


run Sinatra::Application
