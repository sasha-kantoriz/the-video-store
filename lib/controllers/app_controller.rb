class AppController < Sinatra::Base

  include Config
  register Sinatra::Flash
  use Rack::MethodOverride

  enable :sessions
  set :session_secret, Config::OS_ENV[:sessions]
  set :session_expire_after, (60 * 5)
  set :root, Config::OS_ENV[:home]
  set :views, File.join(Config::OS_ENV[:home], 'views')
  include Security_helpers
  include DB_helpers
  
  before do
    headers "Content-Type" => "text/html; charset=utf-8"
  end

end