local http = require 'socket.http' 
local json = require 'json'

function initPlugin()
	registerCommand("w", "wiki")
	registerCommand("wiki","wiki")
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
function wiki(message, channel, nick, prefix)
	if message == "" then
		send(channel, ".w/.wiki <phrase> -- gets first sentence of wikipedia")
		return
	end
	url = "http://en.wikipedia.org/w/api.php?action=opensearch&format=json&search="
	query = string.format("%s%s",url,url_encode(message))

	body, c, l, h = http.request(query)
	result = json.decode(body)
	if result[3][1] == nil then
		send(channel, "No results found")
		return
	end
	output = string.format("%s -- %s",result[3][1], result[4][1])
	send(channel,output)
	
end

