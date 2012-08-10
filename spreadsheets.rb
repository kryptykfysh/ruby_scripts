# spreadsheets.rb

require 'roo'

# creates an Excel Spreadsheet instance
# note roo is read only
s = Excel.new("myspreadsheet.xls")       
   
# first sheet in the spreadsheet file will be used   
s.default_sheet = s.sheets.first  

# returns the content of the first row/first cell in the sheet
s.cell(1,1)                                 

# this also works:
s.cell('A',1)       

s.first_row              # the number of the first row
s.last_row               # the number of the last row
s.first_column           # the number of the first column
s.last_column            # the number of the last column