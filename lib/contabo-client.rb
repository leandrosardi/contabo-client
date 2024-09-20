require 'net/http'
require 'json'
require 'uri'
require 'securerandom'

class ContaboClient
  def initialize(client_id:, client_secret:, api_user:, api_password:)
    @client_id = client_id
    @client_secret = client_secret
    @api_user = api_user
    @api_password = api_password
    @auth_url = 'https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token'
    @api_url = 'https://api.contabo.com/v1/compute/instances'
  end

  def get_access_token
    uri = URI(@auth_url)
    response = Net::HTTP.post_form(uri, {
      'client_id' => @client_id,
      'client_secret' => @client_secret,
      'username' => @api_user,
      'password' => @api_password,
      'grant_type' => 'password'
    })
    JSON.parse(response.body)['access_token']
  end

  def create_secret(password)
    access_token = get_access_token
  
    uri = URI('https://api.contabo.com/v1/secrets')
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    request['Content-Type'] = 'application/json'
    request['x-request-id'] = SecureRandom.uuid
  
    body = {
      name: "Ruby's Contabo Client #{SecureRandom.uuid}",
      value: password,
      type: "password"
    }
  
    request.body = body.to_json
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    data = JSON.parse(response.body)['data'].first
    raise "Failed to create secret. Error: #{response.body}" if data.nil?
    data['secretId']
  end

  def retrieve_images(page: 1, size: 10)
    access_token = get_access_token
    uri = URI('https://api.contabo.com/v1/compute/images')
    params = { page: page, size: size }
    uri.query = URI.encode_www_form(params)
    
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    request['x-request-id'] = SecureRandom.uuid
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    JSON.parse(response.body)
  end
  
  def get_instances(page: 1, size: 10, order_by: nil)
    access_token = get_access_token

    uri = URI(@api_url)
    params = { page: page, size: size }
    params[:orderBy] = order_by if order_by
    uri.query = URI.encode_www_form(params)

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    request['x-request-id'] = SecureRandom.uuid

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def create_instance(image_id:, product_id:, region: 'EU', root_password:, display_name:, user_data: '')
    access_token = get_access_token

    uri = URI(@api_url)
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    request['Content-Type'] = 'application/json'
    request['x-request-id'] = SecureRandom.uuid

    root_password_secret_id = create_secret(root_password)

    body = {
      imageId: image_id,
      productId: product_id,
      region: region,
      rootPassword: root_password_secret_id,
      defaultUser: "root",
      displayName: display_name,
      userData: user_data
    }.compact

    request.body = body.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end
  
  def reinstall_instance(instance_id:, image_id:, root_password:, cloud_init: nil, user_data: '')
    access_token = get_access_token
  
    uri = URI("https://api.contabo.com/v1/compute/instances/#{instance_id}")
    request = Net::HTTP::Put.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    request['Content-Type'] = 'application/json'
    request['x-request-id'] = SecureRandom.uuid
    root_password_secret_id = create_secret(root_password)
    
    body = {
      imageId: image_id,
      rootPassword: root_password_secret_id,
      defaultUser: "root",
      userData: user_data
  }.compact
  
    request.body = body.to_json
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end
  
  def cancel_instance(instance_id:)
    access_token = get_access_token
    uri = URI("#{@api_url}/#{instance_id}")
    request = Net::HTTP::Delete.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    request['x-request-id'] = SecureRandom.uuid
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  rescue StandardError => e
    puts "Error canceling instance: #{e.message}"
    nil
  end
end
