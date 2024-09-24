require_relative '../lib/contabo-client'
require_relative './config.rb'
require 'blackstack-core'
require 'colorize'
require 'json'

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
  # Retrieve instances
  instances = client.get_instances(size: Z)

  # Debug prints to inspect response
  #puts "Response from get_instances:"
  if instances.nil?
    puts "Received nil response from get_instances."
    exit
  else
    puts JSON.pretty_generate(instances)
  end

  # Check for errors in the response
  if instances['error']
    puts "API returned an error: #{instances['error']}"
    exit
  end

  # Check if 'data' key is present and is an array
  if instances['data'].nil? || !instances['data'].is_a?(Array)
    puts "No instances returned or unexpected data format. Response: #{instances.inspect}"
    exit
  end

  unless instances['data'].any?
    puts "No instances found"
    exit
  end

  # Find the instance ID by IP
  instance = instances['data'].find do |h|
    ip_config_v4 = h.dig('ipConfig', 'v4')

    ip_config_v4.is_a?(Hash) && ip_config_v4['ip'] == IP
  end

  if instance.nil?
    puts "Instance with IP #{IP} not found in the retrieved instances."
    exit
  end

  # Use the correct instance ID for cancellation
  instance_id = instance['instanceId']

  # Debug: Print the instance details
  puts "Found instance with IP #{IP}"
  #puts JSON.pretty_generate(instance)

  # Request cancellation
  response = client.cancel_instance(instance_id: instance_id)

  # Print the response
  puts "Cancellation response:"
  if response.nil?
    puts "Received nil response from cancel_instance."
  else
    puts JSON.pretty_generate(response)
  end

rescue StandardError => e
  STDERR.puts "An error occurred: #{e.to_console}".red  
end
