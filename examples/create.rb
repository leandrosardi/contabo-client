require_relative '../lib/contabo-client'  
require_relative './config.rb'  
require 'blackstack-core'
require 'colorize'
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
  root_password = 'HGT121124588ABC'
  # use the following command to generate ssh key
  # ssh-keygen -t ed25519 -b 4096 -C "your_email_here" -f "key_name_here"
  ssh_rsa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPfaX2P18lDbtoZsGC6fcqw7zoAbbNyGlrUI004QCe7 schaudhry722@gmail.com"

  user_data_script = <<~USER_DATA
    #cloud-config
    disable_cloud_init: true
    runcmd:
      - touch /etc/cloud/cloud-init.disabled
      - systemctl stop cloud-init
      - systemctl disable cloud-init
  USER_DATA
  # Create the instance with the retrieved image ID  
  instance = client.create_instance(  
    image_id: image_id,  
    product_id: 'V45',  
    region: 'EU',
    ssh_rsa: ssh_rsa,
    root_password: root_password,  
    display_name: 'MyUbuntu20Instance-root-access-6',
    user_data: user_data_script  
  )  
  
  # Output the created instance details  
  # Commented out since we're using binding.pry for debugging  
  puts JSON.pretty_generate(instance)

rescue StandardError => e  
  STDERR.puts "An error occurred: #{e.to_console}".red  
end