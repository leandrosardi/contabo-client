require_relative '../lib/contabo-client'
require_relative '../config.rb'
require 'json'

# Initialize Contabo client
client = ContaboClient.new(
  client_id: CLIENT_ID,
  client_secret: CLIENT_SECRET,
  api_user: API_USER,
  api_password: API_PASSWORD
)

# Constants
Z = 100

# Retrieve images with error handling
begin
  # Fetch initial set of images
  ret = client.retrieve_images(size: Z)

  # Debugging: Check the actual response structure
  puts "Response from retrieve_images:", JSON.pretty_generate(ret)

  # Handle nil or unexpected response structure
  raise "Unexpected response format or empty response" unless ret && ret['_pagination'] && ret['data']

  # Check total number of pages and fetch additional pages if necessary
  n = ret['_pagination']['totalPages']
  ret = client.retrieve_images(size: n * Z) if n > 1

  # Find the image ID for Ubuntu 20.04
  image = ret['data'].find { |h| h['name'] == 'ubuntu-20.04' }
  raise 'Image not found' if image.nil?
  image_id = image['imageId']

  # Create a secret for the root password
  root_password_secret_id = client.create_secret('121124588')
  puts "root_password_secret_id: #{root_password_secret_id}"

  # Create the instance with the retrieved image ID
  instance = client.create_instance(
    image_id: image_id,
    product_id: 'V45',
    region: 'EU',
    root_password: root_password_secret_id,
    display_name: 'MyUbuntu20Instance-b'
  )

  # Print the created instance details
  puts JSON.pretty_generate(instance)

rescue StandardError => e
  puts "An error occurred: #{e.message}"
  puts e.backtrace
end
