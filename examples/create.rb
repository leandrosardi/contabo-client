require_relative '../lib/contabo-client'
require_relative './config.rb'

# Usage example
client = ContaboClient.new(
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    api_user: API_USER,
    api_password: API_PASSWORD
)

# Find the image ID for Ubuntu 20.04
Z = 100
ret = client.retrieve_images(size:Z)
n = ret['_pagination']['totalPages']
ret = client.retrieve_images(size:n*Z) if n>1
image = ret['data'].find { |h| h['name'] == 'ubuntu-20.04' }
raise 'Image not found' if image.nil?
image_id = image['imageId']

# First, create a secret for the root password (this step is assumed)
root_password_secret_id = client.create_secret('121124588')

# Create the instance with the retrieved image ID
instance = client.create_instance(
  image_id: image_id,
  product_id: 'V45',
  region: 'EU',
  root_password: root_password_secret_id,
  display_name: 'MyUbuntu20Instance'
)

puts JSON.pretty_generate(instance)

