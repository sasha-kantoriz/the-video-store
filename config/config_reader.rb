module Config
  
  CONFIG = YAML.load_file(File.join(Dir.pwd, '../config/config.yml'))
  OS_ENV = {
            :sessions => ENV['SESSION_COOKIE_SECRET'],
            :jwt_sec => ENV['JWT_SECRET'],
            :jwt_iss => ENV['JWT_ISSUER'],
            :home => ENV['JOKESTIME_HOME']
  }
  abort("Something wrong with confuguration. Check 'config.yml'") if CONFIG.nil? || CONFIG.any? {|k,v| v.nil?}
  abort("Some ENV variable(s) not available. Check '~/.bashrc'") if OS_ENV.nil? || OS_ENV.any? {|k,v| v.nil?}
end