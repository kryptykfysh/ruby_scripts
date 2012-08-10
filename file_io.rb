# file_io.rb

# Copying a web page to a local file

require 'rest-client'

wiki_url = "http://en.wikipedia.org/"
wiki_local_filename = "wiki-page.html"

File.open(wiki_local_filename, "w") do |file|
   file.write(RestClient.get(wiki_url))
end

# Write a program that:
#
# 	Reads hamlet.txt from the given URL
# 	Saves it to a local file on your hard drive named "hamlet.txt"
# 	Re-opens that local version of hamlet.txt and prints out every 42nd line to the screen

require 'open-uri'

url = "http://ruby.bastardsbook.com/files/fundamentals/hamlet.txt"
local_filename = 'hamlet.txt'
File.open(local_filename, 'w'){ |file| file.write(open(url).read) }

File.open(local_filename, 'r') do |file|
	file.readlines.each_with_index do |line, index|
		puts line if (index + 1) % 42 == 0
	end
end

# Now that hamlet.txt is on your hard drive, open it again but this time, print only the lines by Hamlet.
# Note that each speaker's name is abbreviated to a few letters and a period. If the speaker's dialogue 
# is longer than a single line, each successive line is indented two spaces.

File.open('hamlet.txt', 'r') do |file|
	hamlet_is_speaking = false
	file.readlines.each do |line|
		if hamlet_is_speaking == true && line.match(/^    (\w|\()+/)
			puts line
		elsif line.match(/^  Ham\. /)
			hamlet_is_speaking = true
			puts line
		else
			hamlet_is_speaking = false
		end
	end
end

# Using the Dir.glob and File.size methods, write a script that targets a directory 
# 	– and all of its subdirectories 
# 	– and prints out the names of the 10 files that take up the most disk space.

dir_name = 'c:/users'
Dir.glob("#{dir_name}/**/*").sort_by{ |filename| File.size(filename) }.reverse[0..9].each do |filename|
	puts "#{filename}: #{File.size(filename)}"
end

# Read the same directory and subdirectories as in the last exercise and determine:
#
# A breakdown of file types (normalize the file extensions) by number of files
# A breakdown of file types by bytes of disk space used.
# Print the results of this analysis in a single text file, in the following spreadsheet-friendly tab-delimited format:
#
# Filetype   Count   Bytes
# TXT   34   102300   
# JPG   8   20050010   
# GIF   5   428400

file_hash = Dir.glob("#{dir_name}/**/*.*").inject({}) do |hash, filename|
	extension = File.basename(filename).split('.')[-1].to_s.downcase
	hash[extension] ||= [0, 0]
	hash[extension][0] += 1
	hash[extension][1] += File.size(filename)
	hash
end
File.open('file_analysis.txt', 'w') do |file|
	file_hash.each do |array|
		output = array.flatten.join("\t")
		file.puts output
		puts output
	end
end

# Reading from the text files generated in the last exercise, use the Google Image Chart API 
# (note that this is different from their Javascript-based Chart API) to draw piecharts based 
# on the data and save those images somewhere on your hard drive.
#
# Read up on the pie chart API here. You can use open-uri to retrieve the file.

require 'open-uri'

BASE_URL = "https://chart.googleapis.com/chart?cht=p&chs=500x300"
rows = File.open("file_analysis.txt"){|f| f.readlines.map{|p| p.strip.split("\t")} }

headers = rows[0]
[1,2].each do |idx|
   labels = []
   values = []
   rows[1..-1].each do |row|
      labels << row[0]
      values << row[idx]
   end
   
   remote_google_img = URI.encode"#{BASE_URL}&chl=#{labels.join('|')}&chd=t:#{values.join(',')}"
	puts remote_google_img
  File.open('file-pie-chart.png', 'w'){|f| 
    f.write(open(remote_google_img))
  }
end