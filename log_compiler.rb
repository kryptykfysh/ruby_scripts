# log_compiler.rb

files = Dir.glob('*.txt')

files.sort! { |x, y| File.mtime(x) <=> File.mtime(y) }

compiled_log = File.open('compiled_log.txt', 'a')

files.each do |file|
	current_file = File.open(file)
	content = current_file.read
	compiled_log.puts File.basename(file)
	compiled_log.puts content
	compiled_log.puts
end

compiled_log.close