env_root = File.dirname(__FILE__)
$: << env_root

ENV['RAILS_ENV'] ||= 'development'

gem 'sinatra', '1.0'
gem 'activesupport', '2.3.8'
gem 'activerecord', '2.3.8'
gem 'rack-flash'
gem 'rack-google_analytics'
gem 'pusher'
gem 'sanitize'

require 'sinatra/base'
require 'active_support'
require 'active_record'
require './lib/helpers'
require 'yaml'
require 'pusher'
require 'sanitize'

require 'rack-flash'
require 'rack/google_analytics'
require 'rack/utils'

require 'core_extensions'

PusherAuth = YAML::load_file(File.expand_path('../config/pusher.yml', env_root))
DbAuth = YAML::load_file(File.expand_path('../config/database.yml', env_root))

ActiveRecord::Base.logger = Logger.new(File.join(env_root, '..', 'log', 'database.log'), 1, 1024000)
ActiveRecord::Base.establish_connection(DbAuth[ENV['RAILS_ENV']])

Dir[File.join(env_root, 'models', '*.rb')].each do |path| 
  autoload File.basename(path).gsub(/\.rb/,'').classify.to_sym, path
end

Pusher.app_id = PusherAuth['app_id']
Pusher.key = PusherAuth['key']
Pusher.secret = PusherAuth['secret']