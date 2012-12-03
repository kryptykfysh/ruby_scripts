# scrape_cf_surgeries.rb

# See: http://ruby.bastardsbook.com/chapters/csurgeries-mechanize/

require 'fileutils'
require 'mechanize'

# Directories for downloaded data files.
DIR = 'data-hold/pages'
FileUtils.makedirs(DIR)

HOME_URL = "http://www.oshpd.ca.gov/commonsurgery/"

# The form field names are pretty horrible, so they're set in a hash here as
# SELECT_FIELD_NAMES['year'] is more legible than 'ctl00$ContentPlaceHolder1$ddlDischargeYear'.
# Bloody .NET
SELECT_FIELD_NAMES = {
  'year'=>'ctl00$ContentPlaceHolder1$ddlDischargeYear',
  'category'=>'ctl00$ContentPlaceHolder1$ddlProcedureCategory',
  'procedure'=>'ctl00$ContentPlaceHolder1$ddlProcedure',
  'county'=>'ctl00$ContentPlaceHolder1$ddlCounty'}

# Downloading any webpage can be error prone.
# Here's some exception handling.
def form_submit_w_exception_handling(frm)
  retries = 3
  begin
    frm.submit(frm.button_with(:value=>'Go'))
  rescue Exception=>e
    puts "Problem: #{e}"
    if retries < 0 
      retries -= 1
      puts "Sleeping...#{retries} left"
      retry
    else
      raise "Unexpected, repeated errors. Shutting down"
    end
  else
    return frm
  end  
end

# Create the mechanize instance and get the page, or raise an error.
mech = Mechanize.new

begin
  mech.get(HOME_URL)
rescue
  raise "Couldn't get homepage"
else
  form = mech.page.form_with(:action=>/default.aspx/) 
end

# The page only has one form so mech.page.forms[0] would work just as well.
# Belts and braces though, this ensures the form we've selected has the action
# we're interested in.
# The form_with method accepts a regular expression.
form = mech.page.form_with(:action=>/default.aspx/)

# Gets a list of the options available for the 'year' field, then selects and submits
# the form with each in turn.
# options[1..-1] skips the first option as this is 'SELECT YEAR', which is useless to us.
# Nested loops for the other fields allow us to load a page for every available option selection.

# beginning of loop for Year dropdown
form.field_with(:name=>SELECT_FIELD_NAMES['year']).options[1..-1].each do |yr_opt|
  form[SELECT_FIELD_NAMES['year']] = yr_opt.value
  #form.submit(form.button_with(:value=>'Go'))
  form = form_submit_w_exception_handling(form)
  puts "Year #{yr_opt.value}: #{mech.page.parser.css('tr').length}"

  
  # beginning of loop for Category dropdown
  form = mech.page.form_with(:action=>/default.aspx/) 
  form.field_with(:name=>SELECT_FIELD_NAMES['category']).options[1..-1].each do |cat_opt|
    form[SELECT_FIELD_NAMES['category']] = cat_opt.value
    form = form_submit_w_exception_handling(form)
    puts "\tCategory #{cat_opt.value}: #{mech.page.parser.css('tr').length}"

    # beginning of loop for Procedure dropdown
    form = mech.page.form_with(:action=>/default.aspx/) 
    form.field_with(:name=>SELECT_FIELD_NAMES['procedure']).options[1..-1].each do |proc_opt|
        form[SELECT_FIELD_NAMES['procedure']] = proc_opt.value
        form = form_submit_w_exception_handling(form)
        puts "\t\tProcedure #{proc_opt.value}: #{mech.page.parser.css('tr').length}"
        
        # beginning of loop for County dropdown
        form = mech.page.form_with(:action=>/default.aspx/) 
        form.field_with(:name=>SELECT_FIELD_NAMES['county']).options[1..-1].each do |county_opt|
            form[SELECT_FIELD_NAMES['county']] = county_opt.value
            form = form_submit_w_exception_handling(form)
            puts "\t\tProcedure #{proc_opt.value}, #{county_opt.value}: #{mech.page.parser.css('tr').length}"
            fname = "#{DIR}/#{yr_opt.value}--#{cat_opt.value}--#{proc_opt.value}--#{county_opt.value}.html"
            File.open(fname, 'w'){|f| f.puts mech.page.parser.to_html}
        end
    end
  end
end