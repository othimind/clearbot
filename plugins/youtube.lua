local http = require 'socket.http' 
local json = require 'json'
Date = require 'pl.Date'

function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end
function getVideoDescription(vid_id)
	url = string.format("http://gdata.youtube.com/feeds/api/videos/%s?v=2&alt=jsonc",vid_id)
	body, c, l, h = http.request(url)
	results = json.decode(body)
	if results["data"] == nil then
		return
	end
	data = results["data"] --["items"][1]
	out = string.format("\x02%s\x02", data["title"])
	if data["duration"] == nil then
		return out
	end
	out = out .. " - length \x02"
	length = data["duration"]
	if math.floor(length / 3600) ~= 0 then
		out = out .. string.format("%dh ", length / 3600)
	end
	if math.floor(length / 60) ~= 0 then
		out = out .. string.format("%dm ", length / 60 % 60)
	end
	out = out .. string.format("%ds\x02", (length % 60))
	if data["rating"] ~= nil then
		out = out .. string.format(" - rated \x02%.2f/5.0\x02 (%d)", data["rating"], data["ratingCount"])
	end
	if data["viewCount"] ~= nil then
		out = out .. string.format(" - \x02%s\x02 views", data["viewCount"])
	end
	upload_time = Date.Format("dd-mm-yyyy"):tostring(Date.Format:parse(data["uploaded"]))
	out = out .. string.format(" - \x02%s\x02 on \x02%s\x02", data["uploader"], upload_time) 
	if data["contentRating"] ~= nil then
		out = out .. " - \x034NSFW\x02"
	end
	out = out .. " - " .. string.format("http://www.youtube.com/watch?v=%s",vid_id)
	return out
end
function initPlugin()
	registerCommand("y", "youtube")
	registerCommand("yt", "youtube")
	registerCommand("youtube", "youtube")
	registerSieve("sieveYoutube")
end

function sieveYoutube(message, channel, nick, prefix)
	if nick == getNick() then
		return
	end
	a,b = string.match(message, "%?v=(.[0-9a-zA-Z]*)&?")
	if a ~= nil then
		send(channel, string.format("%s: %s",nick,getVideoDescription(a)))
	else
		 a,b = string.match(message, "[http://]?youtu.be/(.[0-9a-zA-Z]*)")
		 if a ~= nil then
			send(channel, string.format("%s: %s",nick,getVideoDescription(a)))
		end
	end
end
function youtube(message, channel, nick, prefix)
	url = "http://gdata.youtube.com/feeds/api/videos?v=2&alt=jsonc&max-results=1&q="
	query = url .. url_encode(message)
	body, c, l, h = http.request(query)
	results = json.decode(body)
	if results["data"]["totalItems"] == 0 then
		print("No Results")
		return
	end
	vid_id = results["data"]["items"][1]["id"]
	send(channel, string.format("%s: %s",nick,getVideoDescription(vid_id)))
end
