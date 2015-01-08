local sqlite = require 'luasql.sqlite3'



function dbInit()
	env = assert (sqlite.sqlite3())
	_G.db = assert (env:connect("data/cbdata.db"))
end
