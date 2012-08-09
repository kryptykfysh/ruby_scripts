# loops_and_collections.rb

(1..25).each do |denominator|
	number_divisible = (1..1000).inject(0){ |sum, i| sum + (i % denominator == 0 ? 1 : 0)}
	puts "There are #{number_divisible} numbers divisible by #{denominator} from 1 to 1000"
end

# print out the answers in an 9X9 multiplication table
i = 9

(1..i).each do |first_factor|
	line = ''
	(1..i).each { |second_factor| line += "#{first_factor * second_factor}\t" }
	puts line
end

arr = [1,2,3,4,5]
temp_array = []

temp_array << arr.pop until arr.empty?

arr = temp_array

puts
puts arr.inspect

# Given an array of strings that represent names in "FIRSTNAME LASTNAME" form, 
# use sort_by and split to return an array sorted by last names. For simplicity's sake, 
# assume that each name consists of only two words separated by space (i.e. only "John Doe" 
# and not "Mary Jo Doe").

names = ["John Smith", "Dan Boone", "Jennifer Jane", "Charles Lindy", "Jennifer Eight", "Rob Roy"]

sorted_names = names.sort_by{ |name| name.split(" ").reverse.join.upcase }

puts
puts sorted_names.inspect

# Write an expression that captures only the rows in between the first and last rows.

table="Name,Profit,Loss
James,100,12
Bob,20,42
Sara,50,0
Totals,170,(54)"

puts table.split("\n")[1..-2].inspect

# Write a loop to convert arr_pets into the equivalent hash:
arr_pets = [["dog", "Fido"], ["cat", "Whiskers"], ["pig", "Wilbur"]]

pets_hash = {}

arr_pets.each { |pet|	pets_hash[pet[0]] = pet[1] }

puts ''
puts pets_hash.inspect

# Exercise: Convert an array of arrays into an array of hashes

# In the previous exercise involving pets, it was a simple matter of knowing that the 0-index 
# and 1-index corresponded to pet type and name, respectively.

# Using the sample campaign finance data from above, change each row (sub-array) into an equivalent hash:
data_arr = [
   ["Name", "State", "Candidate", "Amount"],
   ["John Doe", "IA", "Rep. Smithers", "$300"],
   ["Mary Smith", "CA", "Sen. Nando", "$1,000"],
   ["Sue Johnson", "TX", "Rep. Nguyen", "$200"]
]

new_array = []
headings = data_arr.shift
data_arr.each do |data|
	my_hash = {}
	current_index = 0
	headings.each_with_index{ |heading, index| my_hash[heading] = data[index] }
	new_array << my_hash
end

puts ''
puts new_array.inspect

# Exercise: Count frequencies of letters

# Given an arbitrary string, write a method that returns a hash containing:

# 	Each unique character found in the string
# 	The frequency that each type of character appears in that string

# Use a Hash and its ability to use anything, including strings, as keys. 
# Use the split method of String to convert a string into an array of letters.

# Also, you may find the hash's fetch method useful. It takes two arguments: 
# 1) a key and 2) a value to return if there is nothing in the hash at that key. 
# If a value at hash[key] exists, then that is what fetch returns.

def character_frequency string
	character_hash = Hash.new(0)
	string_length = string.length.to_f
	string.each_char{ |c| character_hash[c] += 1 }
	character_hash.each_pair do |k, v|
		character_hash[k] = v / string_length
	end
end

puts ''
puts character_frequency("eeeieeeoueeeiaaaieeeuauaieeieaau").inspect

# Exercise: Make a multiplication table

# Using loops, write a script that will fill a two-dimensional array with the product 
# of each row-index and column-index, for integers 0 through 9.

# The value in arr[4][6] should be 24. And arr[0][4] should be 0. And so on.

def multiplication_table max_size
	table = []
	(0..max_size).each do |row|
		table[row] = []
		(0..max_size).each do |column|
			table[row][column] = row * column
		end
	end
	return table
end

my_table = multiplication_table(9)
puts "\nThe value at location [4][6] is #{my_table[4][6]}"
puts "The value at location [0][4] is #{my_table[0][4]}"

# Write the code in order to:
#
# 	1. Sort presidents by last name in reverse alphabetical order.
# 	2. Create a :full_name key for each hash and set its value to a string in "LASTNAME, FIRSTNAME" format. 
# 		 Then sort the collection, first by party affiliation and then by the full name field.
#
# I've surreptitiously introduced Ruby's Symbol class. Instead of allocating a whole String to use as 
# a key, such as "last_name", I use a Symbol:

presidents = [
 {:last_name=>"Clinton", :first_name=>"Bill", :party=>"Democrat", :year_elected=>1992, :state_residence=>"Arkansas"}, 
 {:last_name=>"Obama", :first_name=>"Barack", :party=>"Democrat", :year_elected=>2008, :state_residence=>"Illinois"}, 
 {:last_name=>"Bush", :first_name=>"George", :party=>"Republican", :year_elected=>2000, :state_residence=>"Texas"}, 
 {:last_name=>"Lincoln", :first_name=>"Abraham", :party=>"Republican", :year_elected=>1860, :state_residence=>"Illinois"}, 
 {:last_name=>"Eisenhower", :first_name=>"Dwight", :party=>"Republican", :year_elected=>1952, :state_residence=>"New York"}
]

sorted_by_last_name = presidents.sort_by{ |hash| hash[:last_name] }.reverse

def sort_by_full_name presidents
	presidents.sort_by do |president|
		president[:full_name] = "#{president[:last_name].upcase}, #{president[:first_name].upcase}"
		"#{president[:party]}-#{president[:full_name]}"
	end
end

puts "\nSorted by last name:"
puts sorted_by_last_name.inspect
puts "\nSorted by full name:"
puts sort_by_full_name(presidents).inspect

# Parsing a collection of tweets

require 'crack'
require 'rest-client'

URL = "http://ruby.bastardsbook.com/files/tweet-fetcher/tweets-data/USAGov-tweets-page-2.xml"
response = RestClient.get(URL)   
if response.code == 200
  xml = Crack::XML.parse(response.body)
  xml['statuses'].each do |status|
  	puts status['text']
   	puts status['created_at']
   	puts '--'
  end
else
   puts "Service is currently down!"
end 