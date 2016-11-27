    module Security_helpers

      def h(text)
        Rack::Utils.escape_html(text)
      end

      def token(username, scopes=['upload_video', 'download_video', 'delete_video', 'like_video'])
        JWT.encode payload(username, scopes), Config::OS_ENV[:jwt_sec], 'HS256'
      end

      def payload(username, scopes)
        {
          exp: Time.now.to_i + 60 * 60,
          iat: Time.now.to_i,
          iss: Config::OS_ENV[:jwt_iss],
          scopes: scopes,
          user: {
            username: username
          }
        }
      end

      def process_request req, scope
        #begin
          options = { algorithm: 'HS256', iss: Config::OS_ENV[:jwt_iss] }
          payload, header = JWT.decode session[:token], Config::OS_ENV[:jwt_sec], true, options

          scopes, user = payload['scopes'], payload['user']
          username = user['username']

          if scopes.include?(scope)
            yield req, username
          else
            flash[:warning] = "Not Available."
            redirect '/login'
          end

        #rescue
          flash[:error] = "Sorry, unauthorized (#{scope}):(#{scopes})"
          redirect '/login'
        #end
      end
    end
