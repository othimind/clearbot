require 'plugins.util.database'
Date = require 'pl.Date'
stringx = require 'pl.stringx'
function initPlugin()
	registerSieve("tellSieve")
	registerCommand("tell", "tell")
end

function tellSieve(message, channel, nick, prefix)
	if nick == getNick() then	
		return
	end
	assert(db:execute("create table if not exists tell (user_to, user_from, message, chan, time,primary key(user_to, message))"))
end

function tell(message, channel, nick, prefix)
	assert(db:execute("create table if not exists tell (user_to, user_from, message, chan, time,primary key(user_to, message))"))
	if message == "get" then
		cur = assert(db:execute(string.format("select user_from, message, time, chan from tell where user_to=lower('%s') order by time",nick)))
		row = cur:fetch({}, "a")
		if row ~= nil then
			while row do
				d1 = Date(os.time())
				d2 = Date(tonumber(row.time))
				output = string.format("%s said %s ago in %s: %s", row.user_from, tostring(d1:diff(d2)), row.chan, row.message)
				send(nick, output)
				row = cur:fetch(row, "a")
			end
			assert(db:execute(string.format("delete from tell where user_to = '%s'",nick)))
		else
			send(nick, "No messages sorry")
		end
		return
	else
		input = stringx.split(message,' ', 2)
		if input[2] ~= nil then
			assert(db:execute(string.format("insert into tell(user_to, user_from, message, chan,time) values('%s','%s','%s','%s','%s')", db:escape(input[1]), nick, db:escape(input[2]), channel, os.time())))
			send(channel, "I'll pass that along.")
		end
	end
	
end