# web_scraping.rb

require 'rubygems'
require 'crack'
require 'open-uri'
require 'rest-client'

# Wikipedia top ssearch terms by alphabetical letter
WURL = 'http://en.wikipedia.org/w/api.php?action=opensearch&namespace=0&suggest=&search='

('A'..'Z').to_a.each do |letter|
	response = RestClient.get("#{WURL}#{letter}", 'User-Agent' => 'Ruby')
	array = Crack::JSON.parse(response)
	puts array.join(', ')
	sleep 0.5
end

puts
puts

# Parsing the data on the recovery.gov website.
require 'crack'
require 'open-uri'

URL = 'http://www.recovery.gov/pages/GetXmlData.aspx?data=recipientHomeMap'

Crack::XML.parse(open(URL).read)['map']['view']['totals']['state'].each do |state|
  puts ['id', 'awarded', 'received', 'jobs'].map{|f| state[f]}.join(', ')
end