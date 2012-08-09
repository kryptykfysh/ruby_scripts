# tweetscan.rb

require "crack"
require "open-uri"
require "rest-client"

def download_tweets user, first_page = 1, last_page = 5
	remote_base_url = "http://api.twitter.com/1/statuses/user_timeline.xml?count=200&screen_name="
	twitter_user = user
	remote_full_url = remote_base_url + twitter_user


	(first_page..last_page).each do |page_num|    
	   puts "Downloading page: #{page_num}"
	   tweets = open("#{remote_base_url}#{twitter_user}&page=#{page_num}").read

	   my_local_filename = "#{twitter_user}-tweets-page-#{page_num}.xml"
	   my_local_file = open(my_local_filename, "w")
	   my_local_file.write(tweets)    
	   my_local_file.close
	   
	   sleep 5
	end
end

def parse_downloaded_tweets user, first_page = 1, last_page = 5
	tweet_basename = "#{user}-tweets-page-"
	total_tweets = []
	(first_page..last_page).each do |page_number|
		tweet_filename = tweet_basename + page_number.to_s + '.xml'

		tweets_file = File.open(tweet_filename)
		parsed_xml = Crack::XML.parse(tweets_file.read)

		tweets = parsed_xml["statuses"]
		tweets.each do |tweet_xml|
			total_tweets << tweet_xml
			puts "Created at: #{tweet_xml['created_at']}"
			puts "Text: #{tweet_xml['text']}"
			puts "Retweet count: #{tweet_xml['retweet_count']}"
			puts '-'
		end
		tweets_file.close
	end
	return total_tweets
end

def tweets_per_day tweets
	time_of_first_tweet = Time.parse(tweets.last['created_at'])
	time_of_last_tweet = Time.parse(tweets.first['created_at'])

	tweets_per_second = tweets.length / (time_of_last_tweet - time_of_first_tweet)
	number_of_tweets_per_day = tweets_per_second * 60 * 60 * 24
end

def tweeters_replied_to tweets
	tweeters_replied_to = []
	tweets.each do |tweet|
		repliee = tweet['in_reply_to_screen_name']
		tweeters_replied_to << repliee unless repliee.nil?
	end
	return tweeters_replied_to
end

if __FILE__ == $0
	unless ARGV.length == 1
		puts "Usage: tweetscan 'Twitter username string'"
		exit
	end

	twitter_user = ARGV[0].downcase
	first_page = 1
	last_page = 5
	download_tweets(twitter_user, first_page, last_page)
	total_tweets = parse_downloaded_tweets(twitter_user, first_page, last_page)
	puts "\nTweets per day: #{tweets_per_day(total_tweets)}"
	puts "\nThere were replies to #{tweeters_replied_to(total_tweets).length} Tweeters"
	puts "The number of unique names is: #{tweeters_replied_to(total_tweets).uniq.length}"
	puts "--"
	puts tweeters_replied_to(total_tweets).uniq.sort
end