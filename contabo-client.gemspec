Gem::Specification.new do |s|
  s.name        = 'contabo-client'
  s.version     = '0.1.1'
  s.date        = '2024-09-24'
  s.summary     = "A Ruby library for managing Contabo instances programmatically. Easily create, cancel, and reinstall Contabo instances directly from your Ruby applications."
  s.description = "A Ruby library for managing Contabo instances programmatically. Easily create, cancel, and reinstall Contabo instances directly from your Ruby applications."
  s.authors     = ["Leandro Daniel Sardi"]
  s.email       = 'leandro@massprospecting.com'
  s.files       = [
    "lib/contabo-client.rb",
  ]
  s.homepage    = 'https://rubygems.org/gems/contabo-client'
  s.license     = 'MIT'
  s.add_runtime_dependency 'net-http', '~> 0.2.2'
  s.add_runtime_dependency 'uri', '~> 0.11.2'
  s.add_runtime_dependency 'json', '~> 2.6.3' 
  s.add_runtime_dependency 'securerandom', '~> 0.3.1' 
end