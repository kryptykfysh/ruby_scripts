# scrape_defense_gov.rb

require 'nokogiri'
require 'open-uri'
require 'fileutils'

PAGES_DIR='data-hold/pages'
FileUtils.makedirs(PAGES_DIR)

BASE_URL = 'http://www.defense.gov/contracts'
S_URL = 'contract.aspx?contractid='

# Get index of most recent script:
index_page = Nokogiri::HTML(open(BASE_URL))

# scrape the homepage to find the latest index
S_C_TABLE_ID = '#ctl00_ContentPlaceHolder_Body_tblContracts'
latest_index = nil
if clinks = index_page.css("#{S_C_TABLE_ID} a")
  latest_index = clinks.map{|c| c['href'].match(/contract.aspx\?contractid=(\d+)/)[1].to_i }.max
else
  "In index page #{BASE_URL}, expected id #{S_C_TABLE_ID}"
end  

STARTING_INDEX = 1
puts "Crawling index from #{STARTING_INDEX} to #{latest_index}"
(STARTING_INDEX..latest_index).each do |idx|
  url = "#{BASE_URL}/#{S_URL}#{idx}"
  puts "Getting #{url}"
  retries = 2
  begin
    resp = Net::HTTP.get_response(URI.parse(url))
    if resp.code.match('200')
      fname = "#{PAGES_DIR}/#{idx}.html"
      File.open(fname, 'w') do |ofile|
        ofile.write(resp.body)
      end
      puts "Saved to #{fname}"
    else
      puts "\tNot a valid page"
    end
  rescue StandardError=>e
    puts "#{idx}: #{e}"
    if retries > 0 
      puts "Retrying #{retries.length} more times"
      retries -= 1
      sleep 40
      retry
    end  
  else
    sleep 3.0 + rand * 3.0
  end
end