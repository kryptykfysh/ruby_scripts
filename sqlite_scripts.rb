# sqlite_scripts.rb

require 'sqlite3'
=begin
db = SQLite3::Database.new('sp500-data.sqlite')

# results are returned as an array
results = db.execute("SELECT * from companies WHERE name LIKE 'C%';")
results.each{ |row| puts row.join(', ')}

# results returned as a hash
db.results_as_hash = true
results = db.execute("SELECT * from companies WHERE name LIKE 'C%';")
puts results[0].class
puts "#{results[0]['name']} is based in #{results[0]['city']}, #{results[0]['state']}"
=end
# Write two SQL queries and combine it with Ruby looping logic. 
# Remember that subqueries can be thought of as "inner queries" to be executed 
# before the query in which they are nested.
#
# Write the Ruby code that will perform the following query without subqueries:
#
# 	SELECT 	companies.*, 
# 					closing_price AS latest_closing_price
# 	FROM 		companies
# 	INNER JOIN stock_prices 
# 	  ON 		company_id = companies.id
# 	WHERE date = (
# 		SELECT 	date 
# 		FROM 		stock_prices AS s2 
# 		ORDER BY date DESC LIMIT 1 )

db = SQLite3::Database.new('sp500-data.sqlite')     
db.results_as_hash = true

inner_results = db.execute("SELECT date FROM stock_prices ORDER BY date DESC LIMIT 1;")
latest_date = inner_results[0]['date']

puts latest_date

results = db.execute("SELECT companies.*, closing_price AS latest_closing_price FROM companies INNER JOIN stock_prices ON company_id = companies.id WHERE date = '#{latest_date}';")
results.each{|row| puts "#{row['name']}: #{row['latest_closing_price']} "}

# Write a program that:
#
# Generates two random numbers, x and y, with y being greater than x. Both numbers should be between 10 and 200.
# Executes a query to find all stock_prices in which the closing_price is between x and y
# Outputs the number of stock_prices that meet the above condition
# Does this operation 10 times

x = rand(10..199)
y = rand((x + 1)..200)

closing_prices_in_range = db.execute("
	SELECT	stock_prices.*
	FROM 		stock_prices
	WHERE		closing_price >= ?
		AND 	closing_price <= ?
	ORDER BY closing_price ASC",
	x, y)

puts "\nThe closing price range was #{x}-#{y}. There were #{closing_prices_in_range.size} matching results."
puts "The lowest closing price result was: #{closing_prices_in_range.first['closing_price']}"
puts "The highest closing price result was: #{closing_prices_in_range.last['closing_price']}"

# Write a program that:
#
# Generates a random number, from 1 to 10, of random alphabetical letters.
# Executes a query to find all the company names that begin with any of the
# set of random letters. 
#
# Outputs the number of companies that meet the above condition
#
# Does this operation 10 times

ALPHABET = ('A'..'Z').to_a

10.times do
	random_letters = ALPHABET.shuffle[0..rand(0..9)]
	select_criteria = random_letters.map{ "name LIKE ?" }.join(" OR ")
	results = db.execute("
		SELECT 	COUNT(1)
		FROM 		companies
		WHERE		#{select_criteria}",
		random_letters.map{ |x| "#{x}%"})
	puts "There are #{results[0][0]} companies with names that begin with #{random_letters.sort.join(', ')}"
end