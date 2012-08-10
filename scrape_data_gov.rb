# scrape_data_gov.rb

require 'nokogiri'
require 'open-uri'
require 'fileutils'
BASE_URL = 'http://explore.data.gov'
BASE_DIR = '/catalog/raw/?&limit=100&page='
LOCAL_DIR = 'data-hold/datagov-pages'

FileUtils.makedirs(LOCAL_DIR) unless File.exists?LOCAL_DIR

# get metainfo from first page:
page = Nokogiri::HTML(open(BASE_URL+BASE_DIR + '1'))

# write the HTML for page 1 to disk
File.open("#{LOCAL_DIR}/1.html", 'w'){|f| f.write(page.to_html)}

last_page_number = page.css("a.end.lastLink.button")[0]['href'].match(/page=(\d+)/)[1].to_i

puts "Iterating from 2 to #{last_page_number}"

for pg_number in 2..last_page_number do
  puts "Getting #{pg_number}"
  File.open("#{LOCAL_DIR}/#{pg_number}.html", 'w') do |f| 
    f.write( open("#{BASE_URL}#{BASE_DIR}#{pg_number}").read )
  end
end