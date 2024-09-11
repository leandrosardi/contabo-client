require_relative '../lib/contabo-client'
require_relative './config.rb'

# Usage example
client = ContaboClient.new(
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    api_user: API_USER,
    api_password: API_PASSWORD
)

ret = client.get_instances

puts JSON.pretty_generate(ret)

puts ret['data'].size
puts ret['_pagination']['totalPages']

ret['data'].each { |h|
    puts '----'
    puts h['name']
    puts h['productId']
    puts h['imageId']
    puts h['ipConfig']['v4']['ip']
}