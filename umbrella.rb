require "http"
require "json"
require "uri"

puts "Where in the world are you located ? "

user_location = gets.chomp

puts "Current weather in #{user_location} :"

google_maps_key = ENV.fetch("GMAPS_KEY")

# We will add this to cover cities that have spaces in their names
# (i.e. New York)

uri_encoded_location = URI.encode_uri_component(user_location)

google_maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{uri_encoded_location}&key=#{google_maps_key}"

raw_google_maps_data = HTTP.get(google_maps_url)

parsed_map_data = JSON.parse(raw_google_maps_data, object_class: OpenStruct)

location_latitude = parsed_map_data.results[0].geometry.location.lat
location_longitude = parsed_map_data.results[0].geometry.location.lng

pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")

pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{location_latitude},#{location_longitude}"

raw_pirate_weather_data = HTTP.get(pirate_weather_url)

#puts raw_pirate_weather_data

weather_data = JSON.parse(raw_pirate_weather_data, object_class: OpenStruct)

probablePrecipitation = weather_data.hourly.data[0].precipProbability*100

umbrella_message = probablePrecipitation >= 10.0 ? "You may need an umbrella" : "You don't need an umbrella"


puts "Current temperature : #{weather_data.currently.temperature} F"

puts " "
puts "Next hour weather : "
puts "="*40
puts " "
puts "Temperature #{weather_data.hourly.data[0].temperature} F"
puts " "
puts "Precipitation probability : #{probablePrecipitation} %"

puts " "
puts "#{umbrella_message}"

puts " "
puts "Summary : #{weather_data.hourly.data[0].summary}"
