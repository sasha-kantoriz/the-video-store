require './init'


#App.configure do
  #File.open("#{Config::OS_ENV[:home]}/../logs/data_mapper.log", "a") {|log| log.puts "=" * 40; log.puts Time.now}
  #DataMapper::Logger.new("#{Config::OS_ENV[:home]}/../logs/data_mapper.log")
  #DataMapper::setup(:default, File.join('sqlite3://', Config::OS_ENV[:home], '../db/development.db'))

  #DataMapper.finalize
  #DataMapper.auto_upgrade!
#end

run App
