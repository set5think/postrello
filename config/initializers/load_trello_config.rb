require 'trello'

TRELLO_CONFIG = YAML.load_file(File.join(Rails.root, 'config', 'trello_config.yml'))

Trello.configure do |config|
  config.developer_public_key = TRELLO_CONFIG['developer_key']
  config.member_token = TRELLO_CONFIG['member_token']
end
