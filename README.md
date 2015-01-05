clearbot
========

A C++ Lua Extensible Architecture Responsive Bot

This irc bot utilises Lua plugins. 

Plugins can be written by including:

````lua
function initPlugin()
	registerPlugin("command", "luaFunctionName", secured(optional))
	registerSieve("luaFunctionName")
end

function luaFunctionName(message, channel, nick, prefix)
	--do some stuff
	send(channel, message)
	sendRaw(text)
	getAPIKey("key")
end
````

