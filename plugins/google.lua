local http = require 'ssl.https' 
local json = require 'json'

function initPlugin()
	registerCommand("google", "google")
	registerCommand("g", "google")
	registerCommand("gis", "gis")
end

function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end


function google(message, channel, nick, prefix)
	if message == "" then
		send(channel, string.format("%s: .google <query> -- returns first google search result", nick))
		return
	end
	googleFunc(message, channel, nick, prefix, false, 1)
end

function gis(message, channel, nick, prefix)
	if message == "" then
		send(channel, string.format("%s: .gis <term> -- finds an image using google images (safesearch off)", nick))
		return
	end
	googleFunc(message, channel, nick, prefix, true, 10)
end

function googleFunc(message, channel, nick, prefix, image, numResult)
	query = string.format("https://www.googleapis.com/customsearch/v1?cx=007629729846476161907:ud5nlxktgcw&fields=items(title,link,snippet)&safe=off&q=%s&key=%s&num=%s",url_encode(message), getAPIKey("google"),numResult)
	if image == true then	
		query = query .. "&searchType=image"
	end
	body, c, l, h = http.request(query)
	results = json.decode(body)
	if results["items"] == nil then	
		send(channel, string.format("%s: No results found", nick))
		return
	end
	items = results["items"]
	intKey = math.random(1,#items)
	item = items[intKey];
	s = string.format("%s: %s --  \x02%s \x02: %s", nick, item["link"], item["title"], item["snippet"])
	s = string.gsub(s, "\n", "")
	send(channel, s)
end