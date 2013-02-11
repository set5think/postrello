require 'trello'

TRELLO_DEVELOPER_KEY = 'xxx'
TRELLO_SECRET = 'xxx'

Trello.configure do |config|
    config.developer_public_key = TRELLO_DEVELOPER_KEY
    config.member_token = TRELLO_SECRET
end
