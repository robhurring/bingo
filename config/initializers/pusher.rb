config_file = File.join(Rails.root, 'config/pusher.yml')
PusherConfig = YAML.load(ERB.new(File.read(config_file)).result)[Rails.env]

Pusher.app_id = PusherConfig['app_id']
Pusher.key = PusherConfig['app_key']
Pusher.secret = PusherConfig['app_secret']
Pusher.logger = Rails.logger