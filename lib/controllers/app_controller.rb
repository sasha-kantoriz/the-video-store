class AppController < Sinatra::Base

  include DB_helpers
  include Security_helpers
  include Config
  register Sinatra::Flash

  enable :sessions, :clean_trace, :inline_templates
  set :session_secret, Config::OS_ENV[:sessions]
  set :root, Config::OS_ENV[:home]
  set :views, File.join(Config::OS_ENV[:home], 'views')

  before do
    headers "Content-Type" => "text/html; charset=utf-8"
  end

end