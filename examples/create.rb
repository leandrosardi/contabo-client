require_relative '../lib/contabo-client'  
require_relative './config.rb'  
require 'json'  
require 'pry'  

# Initialize Contabo client  
client = ContaboClient.new(  
  client_id: CLIENT_ID,  
  client_secret: CLIENT_SECRET,  
  api_user: API_USER,  
  api_password: API_PASSWORD  
)  

# Retrieve images with error handling  
begin  
  # Fetch initial set of images  
  ret = client.retrieve_images(size: 100)  

  raise "Unexpected response format or empty response" unless ret && ret['_pagination'] && ret['data']  

  # Find the image ID for Ubuntu 20.04  
  image = ret['data'].find { |h| h['name'] == 'ubuntu-20.04' }  
  raise 'Image not found' if image.nil?  
  image_id = image['imageId']  

  # Set the root password directly here  
  root_password = '121124588'  

  # Create the instance with the retrieved image ID  
  instance = client.create_instance(  
    image_id: image_id,  
    product_id: 'V45',  
    region: 'EU',  
    root_password: root_password,  
    display_name: 'MyUbuntu20Instance-root-access-1',  
    user_data: "#cloud-config\n"  
  )  
  
  # Replace puts with binding.pry to inspect the instance details  
  binding.pry  

  # Output the created instance details  
  # Commented out since we're using binding.pry for debugging  
  # puts JSON.pretty_generate(instance)  

rescue StandardError => e  
  puts "An error occurred: #{e.message}"  
  puts e.backtrace  
end