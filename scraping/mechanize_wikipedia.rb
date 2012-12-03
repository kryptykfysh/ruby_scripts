# mechanize_wikipedia.rb

require 'mechanize'

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

a.get('http://en.wikipedia.org/') do |page|
  search_result = page.form_with(:id => 'searchform'){ |frm|
    frm.search = 'U.S.'
  }.submit

  puts search_result.parser.css('h1').text
end