require_relative '../lib/contabo-client'
require_relative './config.rb'
require 'blackstack-core'
require 'json'
require 'colorize'
require 'pry'  # Add pry for debugging

# Constants
Z = 100
IP = '62.84.178.201'

# Initialize Contabo client
client = ContaboClient.new(
  client_id: CLIENT_ID,
  client_secret: CLIENT_SECRET,
  api_user: API_USER,
  api_password: API_PASSWORD
)

begin
  # get filtered instance with IP
  instances = client.get_instances(size: Z)
  
  # aux
  total_pages = instances['_pagination']['totalPages']

  if instances['error']
    raise "API returned an error: #{instances['error']}"
  end

  # if API does not return any instance
  if instances['data'].nil? || !instances['data'].is_a?(Array)
    raise "No instances returned or unexpected data format. Response: #{instances.inspect}"
  end

  unless instances['data'].any?
    raise "No instances found"
  end

  # Find the instance ID by IP
  instance = instances['data'].find do |h|
    ip_config_v4 = h.dig('ipConfig', 'v4')

    ip_config_v4.is_a?(Hash) && ip_config_v4['ip'] == IP
  end

  if instance.nil?
    raise "Inspect the case where the instance is not found"
  end

  image_id = instance['imageId']
  
  raise 'Image not found' if image_id.nil?
  
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
  STDERR.puts "An error occurred: #{e.to_console}".red  
end
