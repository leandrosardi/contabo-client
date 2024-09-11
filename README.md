**THIS PROJECT IS UNDER CONSTRUCTION**

# Contabo Client

Ruby gem for performing some infrastructure operations on Contabo via API

## 1. Getting Started

1. Get your Contabo credentials.

Refer to [this article](https://api.contabo.com/#section/Introduction/Getting-Started) about how to get your Contabo credentials.

2. Install **Contabo Client**:

```
gem install contabo-client
```

3. Write your Contabo credentials into a `config.rb` file.

Note that `config.rb` is included in the `.gitignore` file of this project, in order to never push your secrets to a public repository

```ruby
CLIENT_ID = 'INT-**********'
CLIENT_SECRET = 'Sb****************'
API_USER = 'leandro@********.com'
API_PASSWORD = 'SD********fd'
```

3. Start a new Ruby script, requiring `contabo-client` and your `config.rb` file.

```ruby
require_relative '../lib/contabo-client'
require_relative './config.rb'
```

4. Create a new client in your Ruby script.

```ruby
# Usage example
client = ContaboClient.new(
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    api_user: API_USER,
    api_password: API_PASSWORD
)
```

5. Get the list of instances in your Contabo account.

```ruby
ret = client.get_instances

puts JSON.pretty_generate(ret)

puts ret['data'].size
puts ret['_pagination']['totalPages']

ret['data'].each { |h|
    puts '----'
    puts h['name']
    puts h['productId']
    puts h['imageId']
    puts h['ipConfig']['v4']['ip']
}
```

## 2. Creating a New Instances

```ruby
# Create the instance with the retrieved image ID
instance = client.create_instance(
  image_id: image_id,
  product_id: 'V45',
  region: 'EU',
  root_password: root_password_secret_id,
  display_name: 'MyUbuntu20Instance'
)

puts JSON.pretty_generate(instance)
```

## 3. Requesting Instance Reinstallation

```ruby
Z = 100
IP = '84.46.252.181'

# Find the image ID for Ubuntu 20.04
ret = client.retrieve_images(size:Z)
n = ret['_pagination']['totalPages']
ret = client.retrieve_images(size:n*Z) if n>1
image = ret['data'].find { |h| h['name'] == 'ubuntu-20.04' }
raise 'Image not found' if image.nil?
image_id = image['imageId']

# Create a secret for the root password (this step is assumed)
root_password_secret_id = client.create_secret('NewRootPassword123')
puts "root_password_secret_id: #{root_password_secret_id}"

# Get the instance to resinstall
ret = client.get_instances
n = ret['_pagination']['totalPages']
ret = client.retrieve_images(size:n*Z) if n>1
instance_id = ret['data'].find { |h| h['ipConfig']['v4']['ip'] == IP }['instanceId']

# request reinstallation
response = client.reinstall_instance(
  instance_id: instance_id, 
  image_id: image_id, 
  root_password: root_password_secret_id
)

puts JSON.pretty_generate(response)
```

## 3. Requesting Instance Cancelation

```ruby
Z = 100
IP = '84.46.252.181'

# Get the instance to resinstall
ret = client.get_instances
n = ret['_pagination']['totalPages']
ret = client.retrieve_images(size:n*Z) if n>1
instance_id = ret['data'].find { |h| h['ipConfig']['v4']['ip'] == IP }['instanceId']

# request reinstallation
response = client.cancel_instance(
  instance_id: instance_id
)

puts JSON.pretty_generate(response)
```
