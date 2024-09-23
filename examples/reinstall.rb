require_relative '../lib/contabo-client'
require_relative './config.rb'
require 'json'
require 'colorize'
require 'pry'  # Add pry for debugging

# Constants
Z = 100
IP = '84.247.141.169'

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

  # Check for nil response or errors
  if ret.nil? || ret['error'] || !ret['_pagination']
    raise "Inspect error case in retrieve_images"
  end

  n = ret['_pagination']['totalPages']
  if n > 1
    ret = client.retrieve_images(size: n * Z)
  end

  # Handle cases where no data is returned
  if ret['data'].nil? || ret['data'].empty?
    raise "Inspect no data case from API response"
  end

  # Find the image ID for Ubuntu 20.04
  image = ret['data'].find { |h| h['name'] == 'ubuntu-20.04' }
  raise 'Image not found' if image.nil?
  image_id = image['imageId']
  
  # Retrieve instances
  instances = client.get_instances
  n = instances['_pagination']['totalPages']
  if n > 1
    ret = client.get_instances(size: n * Z)
  end

  # Check for nil response or errors
  if instances.nil?
    raise "Inspect the nil response case for instances"
  elsif instances['error']
    raise "Inspect the API error case"
  elsif !instances['_pagination']
    raise "Inspect unexpected response structure"
  elsif instances['data'].nil?
    raise "Inspect the no instances data case"
  end

  # Find the instance ID by IP
  instance = instances['data'].find do |h|
    ip_config_v4 = h.dig('ipConfig', 'v4')

    # Directly compare if 'v4' is a hash
    ip_config_v4.is_a?(Hash) && ip_config_v4['ip'] == IP
  end

  if instance.nil?
    raise "Inspect the case where the instance is not found"
  end

  instance_id = instance['instanceId']

  user_data_script = <<~USER_DATA
    #cloud-config
    disable_cloud_init: true
    runcmd:
      - touch /etc/cloud/cloud-init.disabled
      - systemctl stop cloud-init
      - systemctl disable cloud-init
  USER_DATA

  # Request reinstallation
  response = client.reinstall_instance(
    instance_id: instance_id,
    image_id: image_id,
    root_password: 'NewRootPassword123',
    user_data: user_data_script
  )

  exit(0)

rescue => e
  STDERR.puts e.to_console.red
  exit(1)
end
