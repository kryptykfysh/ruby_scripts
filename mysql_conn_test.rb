require 'mysql'

dbh = Mysql.real_connect("213.171.200.63", "fhtestuser", "entropy.0", "ERADARmain")
puts "Server version: " + dbh.get_server_info
dbh.close if dbh