require 'trello'

TRELLO_DEVELOPER_PUBLIC_KEY = 'XXX'
TRELLO_MEMBER_TOKEN = 'XXX'

Trello.configure do |config|
    config.developer_public_key = TRELLO_DEVELOPER_PUBLIC_KEY
    config.member_token = TRELLO_MEMBER_TOKEN
end
