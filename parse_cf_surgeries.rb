# parse_cf_surgeries.rb

require 'nokogiri'
require 'sqlite3'

FIELD_NAMES = [['year', 'NUMERIC'],['category', 'VARCHAR'], ['procedure', 'VARCHAR', 'procedure_index' ],['county', 'VARCHAR', 'county_index'], ['hospital', 'VARCHAR', 'hospital_index'],  ['address', 'VARCHAR'], ['discharge_count', 'NUMERIC'], ['median_length_in_days', 'NUMERIC'], ['median_charge_per_stay', 'NUMERIC'] ]

# Set up scrape and text file
TABLE_DIV_ID = "#ctl00_ContentPlaceHolder1_gridHospitalList"      
OFILE = File.open('data-hold/ca-common-surgeries.txt', 'w')
OFILE.puts( FIELD_NAMES.map{|f| f[0]}.join("\t") )

# Set up database; delete existing sqlite file
DBNAME = "data-hold/ca-common-surgeries.sqlite"
File.delete(DBNAME) if File.exists?DBNAME
DB = SQLite3::Database.new( DBNAME )

TABLE_NAME = "surgery_records"
DB_INSERT_STATEMENT = "INSERT into #{TABLE_NAME} values
  (#{FIELD_NAMES.map{'?'}.join(',')})"

# Create table
DB.execute "CREATE TABLE #{TABLE_NAME}(#{FIELD_NAMES.map{|f| "`#{f[0]}` #{f[1]}"}.join(', ')});"
FIELD_NAMES.each do |fn| 
  DB.execute "CREATE INDEX #{fn[2]} ON #{TABLE_NAME}(#{fn[0]})" unless fn[2].nil?
end


Dir.glob("data-hold/pages/*.html").reject{|f| f =~ /All Counties/}.each do |fname|
   meta_info = File.basename(fname, '.html').split('--')
   page = Nokogiri::HTML(open(fname))
   
   page.css("#{TABLE_DIV_ID} tr")[1..-2].each do |tr|
      data_tds = tr.css('td').map{ |td|  
         td.text.gsub(/[$,](?=\d)/, '').gsub(/\302\240|\s/, ' ').strip
      }
    data_row = meta_info + data_tds
      OFILE.puts( data_row.join("\t"))  
      DB.execute(DB_INSERT_STATEMENT, data_row)

   end   
end

OFILE.close