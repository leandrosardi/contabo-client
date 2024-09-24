# ContaboClient Ruby Library

A Ruby library for managing Contabo instances programmatically. Easily create, cancel, and reinstall Contabo instances directly from your Ruby applications.

## Features

- **Instance Creation:** Programmatically create new Contabo instances with custom configurations.

- **Instance Cancellation:** Cancel existing Contabo instances.

- **Instance Reinstallation:** Reinstall operating systems on existing instances.

- **Secure Secret Management:** Automatically handle SSH keys and root passwords securely.

## Installation

```
gem install contabo-client
```

## Configuration

Before using the `ContaboClient`, you need to set up your Contabo API credentials. 

1. Refer to [this article](https://api.contabo.com/#section/Introduction/Getting-Started) about how to get your Contabo credentials.

2. Create a `config.rb`` file in your project with the following content:

```ruby
# config.rb

CLIENT_ID = 'your_contabo_client_id'
CLIENT_SECRET = 'your_contabo_client_secret'
API_USER = 'your_contabo_api_username'
API_PASSWORD = 'your_contabo_api_password'
```

**Note:** Replace the placeholder values with your actual Contabo API credentials. Ensure that this file is kept secure and is not committed to version control systems.

## Usage

Require the library and your configuration:

```ruby
require 'contabo-client'
require_relative './config.rb'

# Initialize Contabo client
client = ContaboClient.new(
  client_id: CLIENT_ID,
  client_secret: CLIENT_SECRET,
  api_user: API_USER,
  api_password: API_PASSWORD
)
```

## Creating an Instance

```ruby
begin
  # Retrieve images
  images = client.retrieve_images(size: 100)
  raise "No images found" unless images['data']

  # Select an image
  image = images['data'].find { |img| img['name'] == 'ubuntu-20.04' }
  raise 'Image not found' if image.nil?

  image_id = image['imageId']

  # Define instance parameters
  root_password = 'YourSecurePassword123!'
  ssh_rsa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPfaX2P18lDbtoZsGC6fcqw7zoAbbNyGlrUI004QCe7 your_email@example.com"
  user_data_script = <<~USER_DATA
    #cloud-config
    disable_cloud_init: true
    runcmd:
      - touch /etc/cloud/cloud-init.disabled
      - systemctl stop cloud-init
      - systemctl disable cloud-init
  USER_DATA

  # Create the instance
  instance = client.create_instance(
    image_id: image_id,
    product_id: 'V45',
    region: 'EU',
    ssh_rsa: ssh_rsa,
    root_password: root_password,
    display_name: 'MyUbuntu20Instance',
    user_data: user_data_script
  )

  puts "Instance created successfully:"
  puts JSON.pretty_generate(instance)

rescue StandardError => e
  STDERR.puts "An error occurred: #{e.message}"
end
```

## Cancelling an Instance

```ruby
begin
  # Define the IP of the instance to cancel
  target_ip = '62.84.178.201'

  # Retrieve instances
  instances = client.get_instances(size: 100)
  raise "Failed to retrieve instances" if instances.nil?

  # Find the target instance by IP
  instance = instances['data'].find do |inst|
    inst.dig('ipConfig', 'v4', 'ip') == target_ip
  end

  raise "Instance with IP #{target_ip} not found" if instance.nil?

  # Cancel the instance
  response = client.cancel_instance(instance_id: instance['instanceId'])
  puts "Cancellation response:"
  puts JSON.pretty_generate(response)

rescue StandardError => e
  STDERR.puts "An error occurred: #{e.message}"
end
```

## Reinstalling an Instance

```ruby
begin
  # Define the IP of the instance to reinstall
  target_ip = '62.84.178.201'

  # Retrieve instances
  instances = client.get_instances(size: 100)
  raise "Failed to retrieve instances" if instances.nil?

  # Find the target instance by IP
  instance = instances['data'].find do |inst|
    inst.dig('ipConfig', 'v4', 'ip') == target_ip
  end

  raise "Instance with IP #{target_ip} not found" if instance.nil?

  # Define reinstallation parameters
  new_image_id = 'new_image_id_here' # Replace with the desired image ID
  new_root_password = 'NewSecurePassword123!'
  user_data_script = '' # Optional user data

  # Reinstall the instance
  response = client.reinstall_instance(
    instance_id: instance['instanceId'],
    image_id: new_image_id,
    root_password: new_root_password,
    user_data: user_data_script
  )

  puts "Reinstallation response:"
  puts JSON.pretty_generate(response)

rescue StandardError => e
  STDERR.puts "An error occurred: #{e.message}"
end
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new feature branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a Pull Request.

Please ensure your code adheres to the existing style and includes appropriate tests.

## License

This project is licensed under the [MIT License](/LICENSE).

## Support

For any questions or support, please open an issue on the [GitHub repository](https://github.com/leandrosardi/contabo-client) or contact the maintainer at [leandro@massprospecting.com](leandro@massprospecting.com).