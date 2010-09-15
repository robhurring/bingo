%w{rubygems benchmark logger yaml pp}.each{ |lib| require lib }

RakeRoot = File.dirname(__FILE__)
Log = Logger.new STDOUT

$: << RakeRoot+'/lib'

desc "Bootstraps the environment"
task :environment do
  require 'environment'
end

namespace :db do
  desc "Migrate the database"  
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate(RakeRoot+'/migrations', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )  
  end  
end
