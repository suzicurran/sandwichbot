require 'rubygems'
require 'oauth'
require 'json'
require 'csv'
require './TwitterAPIKeys.rb'
include TwitterAPIKeys

# Craft check for recent mentions
def craft_check
	baseurl = "https://api.twitter.com"
	path    = "/1.1/statuses/mentions_timeline.json"
	query   = URI.encode_www_form(
	    # "since_id" => "twitterapi",
	    "count" => 5,
	)
	@check_address = URI("#{baseurl}#{path}?#{query}")
	@check_request = Net::HTTP::Get.new @check_address.request_uri
end
craft_check

def send_to_twitter (address, request)
	# Set up HTTP
	http             = Net::HTTP.new address.host, address.port
	http.use_ssl     = true
	http.verify_mode = OpenSSL::SSL::VERIFY_PEER
	# API keys
	set_keys
	# Issue the tweet_request
	request.oauth! http, @consumer_key, @access_token
	http.start
	@response = http.request request
end
send_to_twitter(@check_address, @check_request)

# For each tweet retrieved, check for a sandwich @check_request
def find_sandwich_requests(incoming_tweets)
	most_recent_id_saved = false
    incoming_tweets.each do |x|
        tweet_text = x["text"]
        puts tweet_text
        tweet_text.downcase!
        if tweet_text.include? "@suzicurran make me a sandwich"
    		puts "dumb @check_request with an id of #{x["id"]} found from #{x["user"]["screen_name"]}"
    		#reply "What? Make it yourself."
    	elsif tweet_text.include? "@suzicurran sudo make me a sandwich"
    		puts "smart @check_request with an id of #{x["id"]} found from #{x["user"]["screen_name"]}"
    		# make a sandwich
    		# reply with the sandwich
    	else
    		puts "mention lacks sandwich @check_request"
    	end
    	if most_recent_id_saved == false
    		#set last_key to tweet's id
    		puts "most recent id saved"
    		most_recent_id_saved = true
    	end
    end
end

def mentions_check_response
	incoming_tweets = nil
	if @response.code == '200' then
	  incoming_tweets = JSON.parse(@response.body)
	  find_sandwich_requests(incoming_tweets)
	 else
	  puts "Could not get mentions! " +
	  "Code:#{@response.code} Body:#{@response.body}"
	end
end
mentions_check_response