require "mysql"
require "date"

t = Thread.new do
	while true
		begin
		# connect to the MySQL server
		dbh = Mysql.real_connect("213.171.200.50", "emsonhaigdbadmin", "br9prEbR", "emsonhaigdb")
		 # get server version string and display it
		 puts "----------"
		 puts "#{Time.now}"
		 puts "Server version: " + dbh.get_server_info
		 puts "Connection successful"
		 puts "----------"
	   rescue Mysql::Error => e
		 puts "Error code: #{e.errno}"
		 puts "Error message: #{e.error}"
		 puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
	   ensure
		 # disconnect from server
		 dbh.close if dbh
		end
		sleep 5
	end
end

gets
t.kill
	