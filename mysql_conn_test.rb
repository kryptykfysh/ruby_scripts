require 'mysql'

dbh = Mysql.real_connect("ipaddress", "username", "password", "ERADARmain")
puts "Server version: " + dbh.get_server_info
dbh.close if dbh