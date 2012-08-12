puts "Enter server name:"

server = gets.chomp

puts "Enter search term:"

search = gets.chomp

Dir.chdir("//#{server}/c$/fhservices/ListenerShell/logs")
files = Dir.glob("ListenerShell*")

logfile = File.new("logscan.txt","a+")

files.each do |file|
	puts "Now scanning #{File.absolute_path(file).to_s}."
	match = 0
	lines = File.readlines(file)
	lines.each do |line|
		if line =~ /#{search}/i
			if match == 0
				match = 1
				logfile << "#{File.absolute_path(file).to_s}:\n"
			end
			logfile << "#{line}"
		end
	end
	logfile << "\n"
end
logfile << "Scan complete."
puts "Scan complete."
logfile.close