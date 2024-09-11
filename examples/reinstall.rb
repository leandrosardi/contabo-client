require_relative '../lib/contabo-client'
require_relative './config.rb'

Z = 100
IP = '84.46.252.181'

# Usage example
client = ContaboClient.new(
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    api_user: API_USER,
    api_password: API_PASSWORD
)

# Find the image ID for Ubuntu 20.04
ret = client.retrieve_images(size:Z)
n = ret['_pagination']['totalPages']
ret = client.retrieve_images(size:n*Z) if n>1
image = ret['data'].find { |h| h['name'] == 'ubuntu-20.04' }
raise 'Image not found' if image.nil?
image_id = image['imageId']

# Create a secret for the root password (this step is assumed)
root_password_secret_id = client.create_secret('NewRootPassword123')
puts "root_password_secret_id: #{root_password_secret_id}"

# Get the instance to resinstall
ret = client.get_instances
n = ret['_pagination']['totalPages']
ret = client.retrieve_images(size:n*Z) if n>1
instance_id = ret['data'].find { |h| h['ipConfig']['v4']['ip'] == IP }['instanceId']

# request reinstallation
response = client.reinstall_instance(
  instance_id: instance_id, 
  image_id: image_id, 
  root_password: root_password_secret_id
)

puts JSON.pretty_generate(response)

