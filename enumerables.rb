# enumerables.rb

puts 'Using each_with_index to print only every third letter from A to Z'
('A'..'Z').each_with_index{ |letter, index| puts "\t#{letter}" if (index + 1) % 3 == 0 }

puts "\nUsing map (and one other method), create an array that lists the numbers 0 to -100 in descending order. Without typing all the numbers manually, of course."
puts 101.times.map{ |i| -i }
puts (0..100).map{ |i| -i }

# Create a new array in which every second element is uppercased and backwards.
ark = ['cat', 'dog', 'pig', 'goat']

puts "\nOriginal array: #{ark.inspect}"

def rearrange_array array
	new_array = array.each_with_index.map do |element, index|
		if (index + 1) % 2 == 0
			element.upcase.reverse
		else
			element
		end
	end
	return new_array
end

puts "New array: #{rearrange_array(ark).inspect}"

# Use the select method to select only tweets that have more than 10 retweets.
# Print the number of tweets that meet the criteria and print the content of each tweet.

require 'crack'
require 'rest-client'

URL = "http://ruby.bastardsbook.com/files/tweet-fetcher/tweets-data/USAGov-tweets-page-2.xml"

def get_tweets_from_url url
	response = RestClient.get(URL)   
	if response.code == 200
  	xml = Crack::XML.parse(response.body)
  else
  	'Service is down'
  end
end

def select_retweeted_tweets xml, threshold = 10
	selected_statuses = xml['statuses'].select{ |status| status['retweet_count'].to_i > threshold }
end

tweets = get_tweets_from_url(URL)
popular_tweets = select_retweeted_tweets(tweets, 10)

puts "\nThere are #{popular_tweets.length} tweets that have been retweeted more than 10 times."
popular_tweets.each do |tweet|
	puts tweet['text']
	puts tweet['created_at']
	puts '--'
end

# The Fibonacci sequence using loops!
my_array = [0, 1]
18.times do
	my_array << my_array[-2] + my_array[-1]
end
puts "\nFibonacci sequence using loops: #{my_array.inspect}"

# The Fibonacci sequence using inject

def fibonacci_sequence iterations
	iterations.times.inject([0, 1]){ |a, index| a << a[-2] + a[-1] }
end
puts "\nFibonacci sequence using inject: #{fibonacci_sequence(18).inspect}"

# Convert an array to a hash using inject
data_array = [['dog', 'Fido'], ['cat', 'Whiskers'], ['fish', 'Fluffy']]
puts "\nOriginal array: #{data_array}"

def convert_array_to_hash array
	my_hash = array.inject({}) do |hash, outer_element|
		hash[outer_element[0]] = outer_element[1]
		hash
	end
end

puts "Array converted to hash: #{convert_array_to_hash(data_array).inspect}"

# Convert an array to a hash using inject and merge (computationally slower)
def merge_array_to_hash array
	array.inject({}) { |hash, outer_element| hash.merge({outer_element[0] => outer_element[1]}) }
end

puts "Array converted to hash using merge: #{merge_array_to_hash(data_array).inspect}"