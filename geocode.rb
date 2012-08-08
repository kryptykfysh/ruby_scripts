# geocode.rb

require 'open-uri'
require 'rest-client'
require 'crack'

def get_coordinates_from_address(addr)
	base_google_url = "http://maps.googleapis.com/maps/api/geocode/xml?sensor=false&address="
	response = RestClient.get(URI.encode("#{base_google_url}#{addr}"))
	parsed_response = Crack::XML.parse(response)
	latitude = parsed_response['GeocodeResponse']['result']['geometry']['location']['lat']
	longtitude = parsed_response['GeocodeResponse']['result']['geometry']['location']['lng']

	return "#{latitude}, #{longtitude}"
end

puts get_coordinates_from_address('44 Nevis Avenue, Belfast, BT4 3AE')