require 'plugins.util.database'
local http = require 'socket.http'
local json = require 'json'
stringx = require 'pl.stringx'
function initPlugin()
	registerCommand("weather","weather")
	registerCommand("wea","weather")
end
function weather(message, channel, nick, prefix)
	dbInit()
	assert(db:execute("create table if not exists location(chan, nick, loc,  units, primary key(chan, nick))"))
	message = string.lower(message)
	dontsave = false
	if message == "" then
		cur = assert(db:execute(string.format("select loc, units from location where chan = '%s' and nick = '%s'", channel, nick)))
		row = cur:fetch({}, "a")
		if row ~= nil then
			while row do
				message = row.loc
				row = cur:fetch(row, "a")
			end
		else
			response = string.format("%s: .weather <location> [dontsave] [metric/imperial] -- gets weather data from Wunderground ", nick)
			send(channel, response)
			return
		end	
		cur:close()
	end
	
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
		units = ""
	end
		
	location = stringx.split(message,",")
	if location[1] == nil then
		location[1] = ""
	else
		if location[2] ~= nil then
			location[1]  = location[1] .. ","
		end
	end
	if location[2] == nil then
		location[2] = ""
	end
	query = string.format("%s%s%s%s%s%s","http://api.wunderground.com/api/",getAPIKey("wunderground"),"/geolookup/conditions/forecast/q/",location[1],location[2],".json")
	body, c, l, h = http.request(query)
	results = json.decode(body)
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
	if units == "metric" then
		response = string.format("%s: %s: %s, %sC (H:%sC L:%sC), Humidity: %s, %skm/h | Tomorrow: H:%sC L:%sC", nick, info["city"], info["weather"], info["t_c"], info["h_c"], info["l_c"], info["humid"], info["wind_m"], info["th_c"], info["tl_c"])
	elseif units == "imperial" then
		response = string.format("%s %s: %s, %sF (H:%sF L:%sF), Humidity: %s, %smph | Tomorrow: H:%sF L:%sF", nick, info["city"], info["weather"], info["t_f"], info["h_f"], info["l_f"], info["humid"], info["wind_i"], info["th_f"], info["tl_f"])
	else
		response = string.format("%s %s: %s, %sC/%sF (H:%sC/%sF L:%sC/%sF), Humidity: %s, %skph/%smph | Tomorrow: H:%sC/%sF L:%sC/%sF", nick, info["city"], info["weather"], info["t_c"],info["t_f"], info["h_c"], info["h_f"], info["l_c"], info["l_f"], info["humid"], info["wind_m"], info["wind_i"], info["th_c"], info["th_f"], info["tl_c"], info["tl_f"])
	end
	if dontsave == false then
		res = assert(db:execute(string.format("insert or replace into location(chan, nick, loc, units) values ('%s', '%s', '%s', '%s')", channel, nick, db:escape(location[1]) .. db:escape(location[2]), units)))
	end
	send(channel,response)
end
