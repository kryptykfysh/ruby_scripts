# fyshogiri.rb

require 'nokogiri'
require 'open-uri'

page = Nokogiri::HTML(open("http://ruby.bastardsbook.com/files/hello-webpage.html"))
links = page.css("a")
puts links.length   # => 6
puts links[0].text   # => Click here
puts links[0]["href"] # => http://www.google.com

# Referring back to our sample HTML, write a selector that chooses only the anchor tags 
# in the div that has the id of "references". Print out the text within the anchor tag 
# followed by its URL.

references = page.css("div#references a")
references.each{ |link| puts "#{link.text}: #{link['href']}"}

# Visit the Wikipedia entry for HTML: http://en.wikipedia.org/wiki/HTML
# And highlight one of the labels in the top-right summary box, such as 
# "Filename extension".
#
# Use your web inspector to find the CSS selector for all the labels in the summary box. 
# Use Nokogiri to select the elements and print out their text content.
puts

wiki_page = Nokogiri::HTML(open("http://en.wikipedia.org/wiki/HTML"))
labels = wiki_page.css("div#content div#bodyContent table.infobox tr th")
labels.each do |label|
	puts label.text
end