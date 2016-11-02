require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'ostruct'
require 'digest'
require 'jwt'
require 'base64'

require 'data_mapper'
require 'dm-core'
require 'dm-migrations'
require 'dm-sqlite-adapter'
require 'dm-timestamps'

require './config/config_reader'
require './database'

require './video_store'

set :environment, :development
set :run, false
set :raise_errors, true

run Sinatra::Application
