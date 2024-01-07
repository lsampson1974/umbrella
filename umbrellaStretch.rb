# Let's get the libraries that we need to make this work :

require "http"
require "json"
require "uri"

# Let's ask the user where they are on Earth :

puts "Where in the world are you located ? "

user_location = gets.chomp

# Here's where we gather the data from the APIs :
#------------------------------------------------------------------------------------------------------

# Let's convert the location  the user entered into something that can be used in the call to the API :

uri_encoded_location = URI.encode_uri_component(user_location)

# Now let's get our API keys :

google_maps_key = ENV.fetch("GMAPS_KEY")
pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")

# We can now get the long, lat for the location :

google_maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{uri_encoded_location}&key=#{google_maps_key}"

parsed_map_data = JSON.parse(HTTP.get(google_maps_url), object_class: OpenStruct)

location_latitude = parsed_map_data.results[0].geometry.location.lat
location_longitude = parsed_map_data.results[0].geometry.location.lng

# Let's now create the URL string for the Weather Pirate API and get the weather data that
# we need for the location that was entered.

pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{location_latitude},#{location_longitude}"

#raw_pirate_weather_data = HTTP.get(pirate_weather_url)

weather_data = JSON.parse(HTTP.get(pirate_weather_url), object_class: OpenStruct)

#------------------------------------------------------------------------------------------------------

# Uncomment the line below to test whether or not we are getting weather data for X location :
# puts weather_data

# Now that we have the weather data, let's start extracting what we need to show the user :
#------------------------------------------------------------------------------------------------------


