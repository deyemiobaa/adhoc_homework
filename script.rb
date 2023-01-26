require 'net/http'
require 'digest'

attempts = 0
users = nil

# Retry logic to get the token
while attempts < 3
  begin
    # Get token from endpoint
    url = URI("http://127.0.0.1:8888/auth")

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Get.new(url)

    response = http.request(request)

    token = response["badsec-authentication-token"]

    # Calculate checksum
    checksum = Digest::SHA256.hexdigest("#{token}/users")

    # Request user list
    uri = URI('http://127.0.0.1:8888/users')
    req = Net::HTTP::Get.new(uri)

    
    req["X-Request-Checksum"] = checksum

    response = Net::HTTP.start(uri.hostname, uri.port) {|http|
      http.request(req)
    }

    # Parse response
    users = response.body.split("\n")

    # Exit loop if successful
    break
  rescue
    # Increment attempts on failure
    attempts += 1
  end
end

# Exit with non-zero status code if all attempts failed
if users.nil?
  exit 1
else
  puts users.inspect
end