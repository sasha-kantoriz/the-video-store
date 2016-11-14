class App < AppController
  use Sinatra::Routes::Login
  use Sinatra::Routes::General
  use Sinatra::Routes::UserController
  use Sinatra::Routes::VideoController
  use Sinatra::Routes::VideoProcessing

end