require 'eventmachine'

EM.run do
	require 'em-http'

	EM::HttpRequest.new('http://json-time.appspot.com/time.json').get.callback do |http|
		puts http.response
	end
end