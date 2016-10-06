require 'rubygems'
require 'oauth'
require 'json'
require 'csv'
require './TwitterAPIKeys.rb'
require 'pry'
include TwitterAPIKeys

@ingredients = CSV.read("ingredients_import.csv")
@ingredients.map(&:compact!)

# Craft sandwich post
def craft_sandwich
	primary = @ingredients[0].sample
	secondary = @ingredients[1].sample
	condiment = @ingredients[2].sample
	bread = @ingredients[3].sample
	@sandwich = "#{primary} and #{secondary} with #{condiment} on #{bread}"
end

def craft_tweet
	baseurl = "https://api.twitter.com"
	path    = "/1.1/statuses/update.json"
	@tweet_address = URI("#{baseurl}#{path}")
	@tweet_request = Net::HTTP::Post.new @tweet_address.request_uri
	@tweet_request.set_form_data(
	  "status" => @tweet_to_post,
	)
end

def craft_check
	last_id = File.read("last_id.txt")
	baseurl = "https://api.twitter.com"
	path    = "/1.1/statuses/mentions_timeline.json"
	query   = URI.encode_www_form(
	    "since_id" => last_id.to_i,
	)
	@check_address = URI("#{baseurl}#{path}?#{query}")
	@check_request = Net::HTTP::Get.new @check_address.request_uri
end

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
# passing either (@tweet_address, @tweet_request) or (@check_address, @check_request)

def process_sandwich_requests(incoming_tweets)
	most_recent_id_saved = false
    incoming_tweets.each do |x|
	      tweet_text = x["text"]
	      puts tweet_text
	      tweet_text.downcase!
	    	if (tweet_text.include? "@suzicurran") && (tweet_text.include? "sudo make me a sandwich")
		    	puts "^ smart request with an id of #{x["id"]} found from #{x["user"]["screen_name"]}"
		    	craft_sandwich
		    	@tweet_to_post = "@#{x["user"]["screen_name"]} Okay! Enjoy #{@sandwich}."
		    	craft_tweet
		    	send_to_twitter(@tweet_address, @tweet_request)
		    	process_post_response
				elsif (tweet_text.include? "@suzicurran") && (tweet_text.include? "make me a sandwich")
		    	puts "^ dumb request with an id of #{x["id"]} found from #{x["user"]["screen_name"]}"
		    	@tweet_to_post = "@#{x["user"]["screen_name"]} What? Make it yourself."
		    	craft_tweet
		    	send_to_twitter(@tweet_address, @tweet_request)
		    	process_post_response
	    	else
	    		puts "^ mention lacks sandwich request"
	    	end
	    	if most_recent_id_saved == false
		    	File.write("last_id.txt", x["id"])
		    	most_recent_id_saved = true
    	end
    end
end

def process_check_response
	@incoming_tweets = nil
	if success? then
	  @incoming_tweets = JSON.parse(@response.body)
	 else
	  puts "Could not get mentions! " +
	  "Code:#{@response.code} Body:#{@response.body}"
	end
end

def process_post_response
	outgoing_tweet = nil
	if success? then
	  outgoing_tweet = JSON.parse(@response.body)
	  puts "Successfully sent #{outgoing_tweet["text"]}"
	else
	  puts "Could not send the tweet! " +
	  "Code:#{@response.code} Body:#{@response.body}"
	end
end

def success?
	@response.code == '200'
end

binding.pry
craft_check
send_to_twitter(@check_address, @check_request)
process_check_response
process_sandwich_requests(@incoming_tweets)
