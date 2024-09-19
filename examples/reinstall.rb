require_relative '../lib/contabo-client'
require_relative './config.rb'
require 'json'
require 'pry'  # Add this line to require pry

# Constants
Z = 100
IP = '184.174.34.33'

# Initialize Contabo client
client = ContaboClient.new(
  client_id: CLIENT_ID,
  client_secret: CLIENT_SECRET,
  api_user: API_USER,
  api_password: API_PASSWORD
)

begin
  # Retrieve images
  ret = client.retrieve_images(size: Z)

  # Debug prints to inspect response
  binding.pry  # Use this to inspect the `ret` variable

  # Check for nil response or errors
  if ret.nil? || ret['error'] || !ret['_pagination']
    binding.pry  # Use this to inspect the error case
    exit
  end

  n = ret['_pagination']['totalPages']
  if n > 1
    ret = client.retrieve_images(size: n * Z)
  end

  # Handle cases where no data is returned
  if ret['data'].nil? || ret['data'].empty?
    binding.pry  # Use this to inspect the no data case
    exit
  end

  # Find the image ID for Ubuntu 20.04
  image = ret['data'].find { |h| h['name'] == 'ubuntu-20.04' }
  raise 'Image not found' if image.nil?
  image_id = image['imageId']

  # Create a secret for the root password (you should have a method to generate or retrieve a valid secret)
  root_password_secret_id = client.create_secret('NewRootPassword123')
  binding.pry  # Use this to inspect the root_password_secret_id

  # Retrieve instances
  instances = client.get_instances

  # Debug prints to inspect response
  binding.pry  # Use this to inspect the `instances` variable

  # Check for nil response or errors
  if instances.nil?
    binding.pry  # Use this to inspect the nil response case
    exit
  elsif instances['error']
    binding.pry  # Use this to inspect the API error case
    exit
  elsif !instances['_pagination']
    binding.pry  # Use this to inspect unexpected response structure
    exit
  elsif instances['data'].nil?
    binding.pry  # Use this to inspect the no instances data case
    exit
  end

  # Find the instance ID by IP
  instance = instances['data'].find do |h|
    ip_config_v4 = h.dig('ipConfig', 'v4')
    
    # Debug print to check the structure of 'v4'
    binding.pry  # Use this to inspect ip_config_v4

    # Directly compare if 'v4' is a hash
    ip_config_v4.is_a?(Hash) && ip_config_v4['ip'] == IP
  end

  if instance.nil?
    binding.pry  # Use this to inspect the instance not found case
    exit
  end

  instance_id = instance['instanceId']

  # Request reinstallation
  response = client.reinstall_instance(
    instance_id: instance_id,
    image_id: image_id,
    root_password: 'NewRootPassword123',
    user_data: "#cloud-config\n{}"
  )

  # Print the response
  binding.pry  # Use this to inspect the reinstallation response

rescue StandardError => e
  puts "An error occurred: #{e.message}"
  puts e.backtrace
end
