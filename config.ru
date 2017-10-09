require 'rack/reverse_proxy'

class Application < Rails::Application
    config.middleware.use Rack::Deflater
end

if ENV['BASIC_AUTH_USERNAME'] && ENV['BASIC_AUTH_PASSWORD'] && !ENV['BASIC_AUTH_USERNAME'].empty? && !ENV['BASIC_AUTH_PASSWORD'].empty?
  use Rack::Auth::Basic do |username, password|
    username == ENV['BASIC_AUTH_USERNAME'] && password == ENV['BASIC_AUTH_PASSWORD']
  end
end

use Rack::ReverseProxy do
  	reverse_proxy_options preserve_host: true, replace_response_host: true, x_forwarded_headers: true
  	if ENV['BASIC_AUTH_USERNAME'] && ENV['BASIC_AUTH_PASSWORD'] && !ENV['BASIC_AUTH_USERNAME'].empty? && !ENV['BASIC_AUTH_PASSWORD'].empty?
  	  reverse_proxy '/', ENV['REVERSE_URL'], username: ENV['BASIC_AUTH_USERNAME'], password: ENV['BASIC_AUTH_PASSWORD']
  	else
  	  reverse_proxy '/', ENV['REVERSE_URL']
  	end
end
	
app = proc do |env|
  [ 200, { 'Content-Type' => 'text/plain' }, 'b' ]
end

run app
