Rails.application.config.middleware.use OmniAuth::Builder do
  provider :trello, TRELLO_CONFIG['developer_key'], TRELLO_CONFIG['secret'], :app_name => "postrello"
end
