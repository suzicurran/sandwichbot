require 'rubygems'
require 'oauth'
require 'json'
require 'csv'
require './TwitterAPIKeys.rb'
include TwitterAPIKeys

# Craft sandwich post
# "The USER - PRIMARY and SECONDARY with CONDIMENT on BREAD."
ingredients_array = CSV.read("ingredients_import.csv")
primary = ingredients_array[0].sample
secondary = ingredients_array[1].sample
condiment = ingredients_array[2].sample
bread = ingredients_array[3][0..20].sample
sandwich_post = "Sandwich idea: #{primary} and #{secondary} with #{condiment} on #{bread}."

# Craft request
baseurl = "https://api.twitter.com"
path    = "/1.1/statuses/update.json"
address = URI("#{baseurl}#{path}")
request = Net::HTTP::Post.new address.request_uri
request.set_form_data(
  "status" => sandwich_post,
)

# Set up HTTP
http             = Net::HTTP.new address.host, address.port
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

# API keys
set_keys

# Issue the request
request.oauth! http, @consumer_key, @access_token
http.start
response = http.request request

# Parse and print the Tweet if the response code was 200
tweet = nil
if response.code == '200' then
  tweet = JSON.parse(response.body)
  puts "Successfully sent #{tweet["text"]}"
else
  puts "Could not send the Tweet! " +
  "Code:#{response.code} Body:#{response.body}"
end
