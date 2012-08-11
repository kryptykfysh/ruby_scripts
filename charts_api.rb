# charts_api.rb
require 'launchy'

# Charting the Fibonacci sequence.
# chds=a needs to be in the URL as data values exceed 100
fib = 11.times.inject([0,1]){ |array, number| array << array[-2] + array[-1] }
image_string = "http://chart.googleapis.com/chart?cht=bvs&chds=a&chs=400x250&chd=t:#{fib.join(',')}"

puts "Fibonacci chart link: #{image_string}"
Launchy.open(image_string)

# Charting the cf surgeries scrape database
require 'sqlite3'

DBNAME = "data-hold/ca-common-surgeries.sqlite"
DB = SQLite3::Database.open(DBNAME)
TABLE_NAME = "surgery_records"

# Sum the number of discharges per procedure in the database. 
# Create a horizontal bar chart with labels.

query = "SELECT procedure,
		SUM(discharge_count)
	FROM	surgery_records
	GROUP BY procedure
	ORDER BY procedure DESC"

results = DB.execute(query)

procedures = results.map{|row| row[0].split(' ').map{|s| s[0..3]}[0..2].join.gsub(/[^\w]/,'')}            
discharge_counts = results.map{|row| row[1]}

G_URL = "https://chart.googleapis.com/chart?cht=bhs&chs=400x600&chds=a&chbh=10&chxt=x,y"
chart_url = "#{G_URL}&chd=t:#{discharge_counts.join(',')}&chxl=1:|#{procedures.join('|')}"

Launchy.open(chart_url)

# Show the median cost of Disc Removal (any level) procedures over 2007 to 2009. 
# As I mentioned at the beginning of the project, the OSHPD states that some hospitals do not 
# report median charge data. So add a condition to only include rows where median_charge_per_stay 
# is greater than 0.

query = "SELECT s.hospital, 
	#{
	   [2007,2008,2009].map{ |yr|
	      "(SELECT s#{yr}.median_charge_per_stay FROM #{TABLE_NAME} AS s#{yr} WHERE s#{yr}.county=s.county AND s#{yr}.procedure=s.procedure AND s#{yr}.hospital=s.hospital AND s#{yr}.year=#{yr}) AS mc#{yr}"
	   }.join(",\n")
	}
	FROM surgery_records AS s
	WHERE s.county='Sacramento'
	   AND s.procedure='Disc Removal (any level)'
	   AND s.median_charge_per_stay > 0
	GROUP BY s.hospital
	ORDER by s.hospital, s.year ASC"

results = DB.execute(query)

chd = "&chd=t:" + results.inject([]){ |arr, row|
	   row[1..3].each_with_index{ |yr_pt, idx| arr[idx] ||= []; arr[idx] << yr_pt}
	   arr
	}.map{|a| a.join(',')}.join('|')

g_url = "https://chart.googleapis.com/chart?cht=bvg&chs=500x400&chds=a&chbh=5,2,10&chxt=y"
Launchy.open(g_url + chd)

# Scatterplot of discharge_count and median_charge_per_stay on the x- and y-axis.
q = "SELECT hospital,
		discharge_count, 
		median_charge_per_stay 
  FROM surgery_records 
  WHERE county='Sacramento' 
   	AND procedure='Disc Removal (any level)' 
   	AND median_charge_per_stay > 0 
   	AND year = 2009 
   	AND discharge_count > 1
  ORDER by hospital"      

chd = DB.execute(q).inject([[],[]]){ |arr, row|
	  arr[0] << row[1]
	  arr[1] << row[2]   
	  arr
	}.map{|a| a.join(',')}.join('|')

g_url = "http://chart.googleapis.com/chart?cht=s&chs=500x300&chds=a&chxt=x,y&chd=t:#{chd}"

Launchy.open(g_url)

# 2009 records in which a hospital had more than 50 discharges for a given procedure.
# And, for the hell of it, since this query is so simple, let's run it for each of the procedures 
# – all 37 of them – and generate a web page so we can quickly glance at the scatter plots.

procedures = DB.execute("SELECT DISTINCT procedure from surgery_records")
q="SELECT hospital, discharge_count, median_charge_per_stay FROM surgery_records WHERE 
discharge_count >= 25 AND median_charge_per_stay > 0 AND year = 2009 AND procedure=? ORDER by hospital"

outs = File.open("data-hold/procedures-all-hospitals-cost-vs-discharges.html", 'w')
outs.puts ""
procedures.each do |procedure|
  chd = DB.execute(q, procedure).inject([[],[]]){ |arr, row|
     arr[0] << row[1]
     arr[1] << row[2]   
     arr
  }.map{|a| a.join(',')}.join('|')
  g_url = "http://chart.googleapis.com/chart?cht=s&chs=500x300&chds=a&chxt=x,y&chd=t:#{chd}"

   outs.puts "<img src=#{g_url}>
   	#{procedure}"
end
outs.close

Launchy.open("data-hold/procedures-all-hospitals-cost-vs-discharges.html")