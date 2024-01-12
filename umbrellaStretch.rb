# Let's get the libraries that we need to make this work :

require "http"
require "json"
require "uri"
require "ascii_charts"
require "time_difference"

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

# We need an array to hold the precipitation prediction data :

data_points = Array.new(12) { Array.new(2) }

# We should initialize these variables to use in calculations and
# decisions later :

timeOfPrecipProbability = 0
time_diff_minutes = 0
time_diff_hours = 0

# Let's initialize the weather message which will eventually let the user know what they will need to bring outside :
weather_message = " "

# In order for us to graph, we have to go through the next 12 hours and
# populate with the possible precipitation percentages for each hour, creating data points.
# Let's create a loop specifically for this :

for hours in 0..11 do
   percentagePrecipProbability = weather_data.hourly.data[hours].precipProbability*100

   data_points[hours] = percentagePrecipProbability

end

# We will now figure out at what hour will the precipitation prediction
# be above 10% :

for hours in 0..11 do
  if data_points[hours] >= 10.0
    timeOfPrecipProbability = weather_data.hourly.data[hours].time
        
    possible_precip_type = weather_data.hourly.data[hours].precipType

# There are many types of precipitation : sleet, drizzle, etc.
# We will stick with 2 simple ones : snow and rain.

    if possible_precip_type.downcase.include? "snow"
      weather_message = "You may want to take a shovel."
    elsif possible_precip_type.downcase.include? "rain"
      weather_message = "You may want to bring an umbrella."
    end

    break
  end  

end



# Next, let's calculate the hours and minutes before the next precipitation weather event if within 12 hours, the precipitation prediction is above 10 %.

if timeOfPrecipProbability != 0
    next_hour = Time.at(timeOfPrecipProbability).to_i
    current_hour = Time.at(Time.now).to_i

    time_diff = next_hour - current_hour

    time_diff_minutes = Time.at(time_diff).min
    time_diff_hours = Time.at(time_diff).hour

end

# Lastly, let's only show the graph if the precipitation predictions says the preciptiation will be above 10 % within the next 12 hours :

show_graph = false

# We should have all of the information we need, now let's show the user :

puts " "
puts "Checking the weather at #{user_location}"
puts "Your coordinates are #{location_longitude}, #{location_latitude}."
puts "It is currently #{current_temperature} °F"


if time_diff_hours > 0 && time_diff_hours < 12
  puts "Possible #{possible_precip_type} starting in #{time_diff_hours} hour(s) and #{time_diff_minutes} min(s)."
  show_graph = true

elsif time_diff_minutes > 0 
  puts "Possible #{possible_precip_type} starting in #{time_diff_minutes} min(s)."
  show_graph = true

else
  puts "No precipitation predicted for the next 12 hours."

end  

puts " "

if show_graph
  puts AsciiCharts::Cartesian.new((0...12).to_a.map{|hours| [hours+1, data_points[hours]]}, :title => 'Hours from now vs Precipitation probability', :bar => true).draw
end

puts weather_message
