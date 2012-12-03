# tweet_parse.rb

require 'crack'

tweet_basename = 'kryptykphysh-tweets-page-'
first_page = 1
last_page = 5

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

total_tweet_count = total_tweets.length

# tweets are listed in chronological order, most recent first
most_recent_tweet = total_tweets.first
earliest_tweet = total_tweets.last

most_recent_time = Time.parse(most_recent_tweet['created_at'])
earliest_time = Time.parse(earliest_tweet['created_at'])

tweets_per_second = total_tweet_count / (most_recent_time - earliest_time)
tweets_per_day = tweets_per_second * 60 * 60 * 24

puts "Tweets per day: #{tweets_per_day}"

# tweeters replied to
def tweeters_replied_to tweets
	tweeters_replied_to = []
	tweets.each do |tweet|
		repliee = tweet['in_reply_to_screen_name']
		tweeters_replied_to << repliee unless repliee.nil?
	end
	return tweeters_replied_to
end

puts "There were replies to #{tweeters_replied_to(total_tweets).length} Tweeters"
puts "The number of unique names is: #{tweeters_replied_to(total_tweets).uniq.length}"
puts "--"
puts tweeters_replied_to(total_tweets).uniq.sort

# tweet text analysis
total_chars_in_tweets = 0
word_list = {}

total_tweets.each do |tweet|
	txt = tweet['text'].downcase
	total_chars_in_tweets += txt.length
	# Regular expression to select any string of consecutive
  # alphabetical letters (with optional apostrophes and hypens)
  # that are surrounded by whitespace or end with a punctuation mark 
  words = txt.scan(/(?:^|\s)([a-z'\-]+)(?:$|\s|[.!,?:])/).flatten.select{|w| w.length > 1}

  # Use of the word_list Hash to keep a list of different words
  words.each do |word|
  	word_list[word] ||= 0
  	word_list[word] += 1
  end
end

puts "Total characters used: #{total_chars_in_tweets}"
puts "Average tweet length in chars: #{total_chars_in_tweets/total_tweet_count}"
puts "Number of unique words: #{word_list.length}"
puts "Total number of words: #{word_list.inject(0) {|sum, w| sum += w[1]}}"

# sort word list by frequency of word, descending
word_list = word_list.sort_by{|w| w[1]}.reverse

puts "\nTop 20 most frequent words:"
word_list[0..19].each do |w|
	puts "#{w[0]}:\t#{w[1]}"
end

puts "\nTop 20 most frequent words more than 4 characters long:"
word_list.select{|w| w[0].length > 4}[0..19].each do |w|
	puts "#{w[0]}:\t#{w[1]}"
end

puts "\nLongest word:"
longest_word = word_list.max_by{|w| w[0].length}[0]
puts "#{longest_word}: #{longest_word.length}"