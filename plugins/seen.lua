require 'plugins.util.database'
Date = require 'pl.Date'
function initPlugin()
	registerSieve("seenSieve")
	registerCommand("seen", "seen")
end

function seenSieve(message, channel, nick, prefix)
	if nick == getNick() then	
		return
	end
	assert(db:execute("create table if not exists seen(name, time, quote, chan, primary key(name, chan))"))
	assert(db:execute(string.format("insert or replace into seen(name, time, quote, chan) values('%s','%s','%s','%s')", nick, os.time(), db:escape(message),channel)))
end

function seen(message, channel, nick, prefix)
	if message == "" then
		send(channel,"seen <nick> -- Tell when a nickname was last in active in irc")
	end
	if string.lower(message:gsub("%s+", "")) == getNick() then
		send(channel, "You need to get your eyes checked.")
		return
	end
	if string.lower(message:gsub("%s+", "")) == nick then
		send(channel, "Have you looked in a mirror lately?")
		return
	end
	cur = assert(db:execute(string.format("select name, time, quote from seen where name = '%s' and chan = '%s'", db:escape(message), channel)))
	row = cur:fetch({}, "a")
	
		if row ~= nil then
			while row do
				d1 = Date(os.time())
				d2 = Date(tonumber(row.time))
				response = string.format("%s was last seen %s ago saying '%s'", row.name,tostring(d1:diff(d2)) ,row.quote) 
				row = cur:fetch(row, "a")
			end 
		else
			output = string.format("I've never seen %s", message)
			send(channel, output)
			return
		end
	send(channel, response)
end