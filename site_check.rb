require 'open-uri'

SITES = ['benchmarketing.com.au', 'pellicano.com.au', 'scribblevision.com.au']

while true
  puts "\nChecking sites at #{Time.now.localtime.strftime('%H:%M:%S')} -"
  SITES.each do |site|
    io_thing = open("http://#{site}")
	site_status = io_thing.status[0]
	result = (site_status == '200' && 'OK') || 'Down'
	puts "#{site}: #{result}"
  end
  sleep(5*60)
end