require 'plugins.util.database'
local http = require 'socket.http'
local json = require 'json'
function initPlugin()
	registerCommand("weather","weather")
	registerCommand("wea","weather")
end
--function getAPIKey(stuff)
--	return "01c359b7f7bcf231"
--end
function weather(message, channel, nick, prefix)
	assert(db:execute("create table if not exists location(chan, nick, loc,  units, primary key(chan, nick))"))
	message = string.lower(message)
	s,e = string.find(message,"dontsave")
	if s ~= nil then
		dontsave = true;
		message = string.gsub(message, "dontsave", "")
	end
	s,e = string.find(message, "metric")
	n,e = string.find(message, "imperial")
	if s ~= nil then
		units = "metric"
		message = string.gsub(message, "metric", "")
	elseif n ~= nil then
		units = "imperial"
		message = string.gsub(message, "imperial", "")
	else
		units = "metric"
	end
		if message == "" then
		cur = assert(db:execute(string.format("select loc, units from location where chan = '%s' and nick = '%s'", channel, nick)))
		row = cur:fetch({}, "a")
		if row ~= nil then
			while row do
				message = row.loc
				units = row.units
				row = cur:fetch(row, "a")
			end
		else
			response = string.format("%s: .weather <location> [dontsave] [metric/imperial] -- gets weather data from Wunderground ", nick)
			send(channel, response)
			return
		end
		
	end
	message = string.gsub(message, " ", "")
	location = string.gmatch(message, "%a+")
	loc = {}
	i = 1
	for item in location do
		loc[i] = item
		i = i + 1
	end
	if loc[1] == nil then
		loc[1] = ""
	else
		loc[1]  = loc[1] .. ","
	end
	if loc[2] == nil then
		loc[2] = ""
	end
	query = string.format("%s%s%s%s%s%s","http://api.wunderground.com/api/",getAPIKey("wunderground"),"/geolookup/conditions/forecast/q/",loc[1],loc[2],".json")
	--print(query)
	body, c, l, h = http.request(query)
	results = json.decode(body)
	--print(body)
	if results["response"]["results"] ~= nil then
		text = string.format("%s: Multiple results found: ", nick)
		things = results["response"]["results"]
		for key, value in  pairs(things) do
			text = text .. value["city"] .. ", " .. value["state"] .. "," .. value["country_name"] .. "; "
		end
		send(channel, text)
		return
	end
	if results["current_observation"] == nil then
		send(channel, results["response"]["error"]["description"])--string.format("Could not find weather for %s", message))
		return
	end
	sf = results["forecast"]["simpleforecast"]["forecastday"][1]
	tom = results["forecast"]["simpleforecast"]["forecastday"][2]
	info = {}
	info["city"] = results["current_observation"]["display_location"]["full"]
	info["t_f"] = results["current_observation"]["temp_f"]
	info["t_c"] = results["current_observation"]["temp_c"]
	info["weather"] = results["current_observation"]["weather"]
	info["h_f"] = sf["high"]["fahrenheit"]
	info["h_c"] = sf["high"]["celsius"]
    info["l_f"] = sf["low"]["fahrenheit"]
    info["l_c"] = sf["low"]["celsius"]
    info["th_f"] = tom["high"]["fahrenheit"]
    info["th_c"] = tom["high"]["celsius"]
    info["tl_f"] = tom["low"]["fahrenheit"]
    info["tl_c"] = tom["low"]["celsius"]
	info["humid"] = results["current_observation"]["relative_humidity"]
	info["wind_m"] = results["current_observation"]["wind_kph"]
	info["wind_i"] = results["current_observation"]["wind_mph"]
	lat = results["current_observation"]["latitude"]
	lon = results["current_observation"]["longitude"]
	--print(body)
	if units == "metric" then
		response = string.format("%s: %s: %s, %sC (H:%sC L:%sC), Humidity: %s, %s | Tomorrow: H:%sC L:%sC", nick, info["city"], info["weather"], info["t_c"], info["h_c"], info["l_c"], info["humid"], info["wind_m"], info["th_c"], info["tl_c"])
	else
		response = string.format("%s %s: %s, %sF (H:%sF L:%sF), Humidity: %s, %s | Tomorrow: H:%sF L:%sF", nick, info["city"], info["weather"], info["t_f"], info["h_f"], info["l_f"], info["humid"], info["wind_i"], info["th_f"], info["tl_f"])
	end
	--print(response)
	if dontsave == nil then
		res = assert(db:execute(string.format("insert or replace into location(chan, nick, loc, units) values ('%s', '%s', '%s', '%s')", channel, nick, db:escape(loc[1]) .. db:escape(loc[2]), units)))
	end
	send(channel,response)
end

--weather("","#sexbarge","othi","d")
