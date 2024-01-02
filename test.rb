require "http"
require "json"

puts ENV.fetch("GMAPS_KEY")

user_location = "Chicago"

gmaps_key = ENV.fetch("GMAPS_KEY")

gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{gmaps_key}"

raw_gmaps_data = HTTP.get(gmaps_url)

parsed_gmaps_data = JSON.parse(raw_gmaps_data, object_class: OpenStruct)

location_latitude = parsed_gmaps_data.results[0].geometry.location.lat
location_longitude = parsed_gmaps_data.results[0].geometry.location.lng

pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")

pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{location_latitude},#{location_longitude}"

raw_pirate_weather_data = HTTP.get(pirate_weather_url)

parsed_pirate_weather_data = JSON.parse(raw_pirate_weather_data, object_class: OpenStruct)

puts raw_pirate_weather_data
