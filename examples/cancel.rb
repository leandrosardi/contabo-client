require_relative '../lib/contabo-client'
require_relative '../config.rb'
require 'json'

# Constants
Z = 100
IP = '84.46.252.181'

# Initialize Contabo client
client = ContaboClient.new(
  client_id: CLIENT_ID,
  client_secret: CLIENT_SECRET,
  api_user: API_USER,
  api_password: API_PASSWORD
)

begin
  # Retrieve instances
  instances = client.get_instances

  # Debug prints to inspect response
  puts "Response from get_instances:"
  puts JSON.pretty_generate(instances)

  # Check for nil response or errors
  if instances.nil? || instances['error'] || !instances['_pagination']
    puts "Failed to retrieve instances or API returned an error."
    puts "Response: #{instances.inspect}"
    exit
  end

  # Find the instance ID by IP
  instance = instances['data'].find { |h| h['ipConfig']['v4']['ip'] == IP }
  raise 'Instance not found' if instance.nil?
  instance_id = instance['instanceId']

  # Request cancellation
  response = client.cancel_instance(instance_id: instance_id)

  # Print the response
  puts "Cancellation response:"
  puts JSON.pretty_generate(response)

rescue StandardError => e
  puts "An error occurred: #{e.message}"
  puts e.backtrace
end
