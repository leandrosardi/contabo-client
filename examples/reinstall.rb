require_relative '../lib/contabo-client'
require_relative '../config.rb'
require 'json'

# Constants
Z = 100
IP = '89.147.102.35'

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
  puts "Response from retrieve_images:"
  puts JSON.pretty_generate(ret)

  # Check for nil response or errors
  if ret.nil? || ret['error'] || !ret['_pagination']
    puts "Failed to retrieve images or API returned an error."
    puts "Response: #{ret.inspect}"
    exit
  end

  n = ret['_pagination']['totalPages']
  if n > 1
    ret = client.retrieve_images(size: n * Z)
  end

  # Handle cases where no data is returned
  if ret['data'].nil? || ret['data'].empty?
    puts "No images returned from API."
    exit
  end

  # Find the image ID for Ubuntu 20.04
  image = ret['data'].find { |h| h['name'] == 'ubuntu-20.04' }
  raise 'Image not found' if image.nil?
  image_id = image['imageId']

  # Create a secret for the root password (you should have a method to generate or retrieve a valid secret)
  root_password_secret_id = client.create_secret('NewRootPassword123')
  puts "root_password_secret_id: #{root_password_secret_id}"

  # Retrieve instances
  instances = client.get_instances

  # Debug prints to inspect response
  puts "Response from get_instances:"
  puts JSON.pretty_generate(instances) unless instances.nil?

  # Check for nil response or errors
  if instances.nil?
    puts "Failed to retrieve instances: Response is nil."
    exit
  elsif instances['error']
    puts "API returned an error: #{instances['error']}"
    exit
  elsif !instances['_pagination']
    puts "Unexpected response structure: '_pagination' key is missing."
    exit
  elsif instances['data'].nil?
    puts "No instances data returned from API."
    exit
  end

  # Find the instance ID by IP
  instance = instances['data'].find do |h|
    h['ipConfig'] && h['ipConfig']['v4'] &&
    h['ipConfig']['v4'].any? { |ip_entry| ip_entry['ip'] == IP }
  end

  if instance.nil?
    puts "Instance with IP #{IP} not found."
    exit
  end

  instance_id = instance['instanceId']

  # Request reinstallation
  response = client.reinstall_instance(
    instance_id: instance_id,
    image_id: image_id,
    root_password: root_password_secret_id
  )

  # Print the response
  puts "Reinstallation response:"
  puts JSON.pretty_generate(response)

rescue StandardError => e
  puts "An error occurred: #{e.message}"
  puts e.backtrace
end
