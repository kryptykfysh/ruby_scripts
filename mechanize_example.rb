# mechanize_example.rb
# see: http://mechanize.rubyforge.org/GUIDE_rdoc.html

require 'mechanize'

agent = Mechanize.new
page = agent.get('http://google.com/')

google_form = page.form('f')
google_form.q = 'ruby mechanize'
page = agent.submit(google_form)

pp page