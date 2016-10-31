class Hash
  def self.to_ostructs(obj, memo={})
    return obj unless obj.is_a? Hash
    os = memo[obj] = OpenStruct.new
    obj.each { |k,v| os.send("#{k}=", memo[v] || to_ostructs(v, memo)) }
    os
  end
end


class ConfigReader

  def initialize
    @config = Hash.to_ostructs(YAML.load_file(File.join(Dir.pwd, '../config/config.yml')))
  end

  def get_config
    @config
  end
  
end

@config_reader = ConfigReader.new
$config = @config_reader.get_config

@os_env = {
  :sessions => ENV['SESSION_COOKIE_SECRET'],
  :jwt_sec => ENV['JWT_SECRET'],
  :jwt_iss => ENV['JWT_ISSUER']
}

abort("Not available ENV variables.") if @os_env.any? {|k,v| v.nil?}
