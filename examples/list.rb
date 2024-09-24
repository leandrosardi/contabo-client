require_relative '../lib/contabo-client'
require_relative './config.rb'
require 'blackstack-core'
require 'colorize'
require 'json'

# Initialize Contabo client
client = ContaboClient.new(
  client_id: CLIENT_ID,
  client_secret: CLIENT_SECRET,
  api_user: API_USER,
  api_password: API_PASSWORD
)

begin
  # Retrieve instances with error handling
  ret = client.get_instances

  # Debugging: Check the actual response structure
  puts "Response from get_instances:", JSON.pretty_generate(ret)

  # Handle nil or unexpected response structure
  unless ret && ret['data'] && ret['_pagination']
    raise "Unexpected response format or empty response"
  end

  # Output the total number of instances and total pages
  puts "Number of instances:", ret['data'].size
  puts "Total pages:", ret['_pagination']['totalPages']

  # Iterate through each instance and print details
  ret['data'].each do |h|
    puts '----'
    puts "Name: #{h['name']}"
    puts "Product ID: #{h['productId']}"
    puts "Image ID: #{h['imageId']}"
    ip_config = h.dig('ipConfig', 'v4', 'ip')  # Use dig to safely access nested keys
    puts "IPv4 IP: #{ip_config}" if ip_config
  end

rescue StandardError => e
  STDERR.puts "An error occurred: #{e.to_console}".red  
end
