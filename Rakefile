require "sequel"

namespace :db do
  task :migrate, [:version] do |task, args|
    DB = Sequel.sqlite("db/jokestime.db")
    Sequel.extension :migration
    version = Integer(args[:version]) if args[:version]
    Sequel::Migrator.apply(DB, "db/migrations", version)
  end
end