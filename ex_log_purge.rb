require 'date'

puts "Please enter the server name: "
server = gets.chomp

UNITS = %W(B KB MB GB TB).freeze

def as_size number
	if number.to_i < 1024
		exponent = 0
	else
		max_exp = UNITS.size - 1
		exponent = (Math.log(number) / Math.log(1024)).to_i
		exponent = max_exp if exponent > max_exp
		number /= 1024 ** exponent
	end
	"#{number} #{UNITS[exponent]}"
end

log_file_path = ""
search_date = Date.today - 5
file_count = 0
total_bytes = 0

Dir.chdir("//#{server}/domains")
search_directories = []
Dir.glob("*/").each { |x| search_directories << x if x =~ /[0-9a-zA-Z]\// }

if server =~ /((10.216.(12|7).|fhlinux)\d+)|10.1.33.1(0|1)/i
	log_file_path = "user/logfiles/ex*.log"
elsif server =~ /((10.216.8.|winweb|winnas)\d+)|10.1.33.160/i
	log_file_path = "user/logfiles/*/u_ex*.log"
elsif server =~ /((iis|fastweb|nas)\d+)|(premier(silver|gold))/i
	log_file_path = "user/logfiles/*/ex*.log"
else
	puts "#{server} not valid."
	abort ("Server not found")
end
	
search_directories.each do |current_dir|
	puts "Checking #{current_dir}"
	Dir.glob("#{current_dir}*/#{log_file_path}") do |file|
		if File.mtime(file).to_date <= search_date
			file_count += 1
			total_bytes += File.size(file)
			File.delete(file)
			puts "#{file}"
		end
	end
end

puts "Phear the Ruby-fu of Kryptyk Physh!"
puts "#{server}: #{file_count} files found. #{as_size(total_bytes)} deleted."