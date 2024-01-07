# Let's get the libraries that we need to make this work :

require "http"
require "json"
require "uri"
require "ascii_charts"

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

weather_data = JSON.parse(HTTP.get(pirate_weather_url), object_class: OpenStruct)

#------------------------------------------------------------------------------------------------------

# Uncomment the line below to test whether or not we are getting weather data for X location :
# puts weather_data

# Now that we have the weather data, let's start extracting what we need to show the user :
#------------------------------------------------------------------------------------------------------

# Let's get the current temp and possible preciptation for the next hour :

current_temperature = weather_data.currently.temperature

possible_precip_type_next_hour = weather_data.hourly.data[0].precipType

# We need a 2d array for the graph :

data_points = Array.new(12) { Array.new(2) }

# In order for us to graph, we have to go through the next 12 hours and
# populate with the possible precipitation percentages for each hour, creating data points.
# Let's create a loop specifically for this :

# We're setting this as a default in case no precipitation probabilities above 10 % are found in the next
# 12 hours.  
hour_of_possible_precipitation = 99 

# We now need to collect the precipitation probability data for the next 12 hours :
# If at least 1 of those hours have a precipitation of > 10.0 %, then record the hour and
# afterwards, we'll calculate the differences between now and that hour.  

for hours in 0..11 do
  data_points[hours][0] = hours+1
  data_points[hours][1] = weather_data.hourly.data[hours].precipProbability

  if data_points[hours][1] >= 10.0 
    hour_of_possible_precipitation = hours+1
  end

end

current_time = Time.now

# Uncomment below to test the time calculations :
hour_of_possible_precipitation = 5

#new_time = time + 2.hours
if hour_of_possible_precipitation != 99
  possible_precip_time = current_time + 2.hours
end


