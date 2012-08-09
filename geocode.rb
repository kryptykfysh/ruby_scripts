# geocode.rb

# Simple script to return latitude and longtitude from an address string
# using the Google geocode API.
# For more info see https://developers.google.com/maps/documentation/geocoding/

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

if $0 == __FILE__
	unless ARGV.length == 1
		puts "Usage: geocode 'address string'"
		exit
	end
	puts get_coordinates_from_address(ARGV[0])
end