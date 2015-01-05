clearbot
========

A C++ Lua Extensible Architecture Responsive Bot

This irc bot utilises Lua plugins. 

Plugins can be written by including:

````lua
require 'plugins.util.database' --for plugins that need the sqlite3 database

function initPlugin()
	registerCommand("command", "luaFunctionName", secured(optional))
	registerSieve("luaFunctionName")
end

function luaFunctionName(message, channel, nick, prefix)
	--do some stuff
	send(channel, message)
	sendRaw(text)
	getAPIKey("key")
end
````
registerCommand registers a new command, and links it to the appropriate Lua function. The optional parameter 'secured' is a boolean value that sets if this should be 'admin-only'. The bot owner will always be able to run such commands. The function signature of the function registered must be 'message, channel, nick, prefix'. The function should not return anything.

registerSieve registers a function that will be run for every line of text the bot detects. The function registered should have the signature 'message, channel, nick, prefix' and should not return anything.
Clearbot has the following dependencies:

lua
yaml-cpp
soci
soci-sqlite3
luabind
IRCClient (modified)
boost

Clearbot Plugins that utilise the database require:

luasql (sqlite3)
