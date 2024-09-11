require_relative '../lib/contabo-client'
require_relative './config.rb'

# Usage example
client = ContaboClient.new(
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    api_user: API_USER,
    api_password: API_PASSWORD
)

ret = client.retrieve_images(size:100)

puts ret['data'].size
puts ret['_pagination']['totalPages']

puts '-----------------'

ret['data'].sort_by { |h| h['name'] }.each { |h|
    puts '----'
    puts h['imageId']
    puts h['name']
}