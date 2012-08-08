require 'open-uri'

remote_base_url = "http://en.wikipedia.org/wiki"
start_year = 1973
end_year = 1975

compiled_file_name = "#{start_year}-#{end_year}.html"
puts "Creating compilation file: #{compiled_file_name}"
compiled_file = open(compiled_file_name, "w")

(start_year..end_year).each do |year|
	full_url = "#{remote_base_url}/#{year}"
	puts "Reading: #{full_url}"
	page_data = open(full_url).read
	file_name = "my_copy_of-#{year}.html"
	local_file = open(file_name, "w")
	puts "Writing to: #{file_name}"
	local_file.write(page_data)
	local_file.close
	compiled_file.write(page_data)
	sleep 1
end

compiled_file.close
puts "Compilation complete"
