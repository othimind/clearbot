local sqlite = require 'luasql.sqlite3'

env = assert (sqlite.sqlite3())

_G.db = assert (env:connect("data/cbdata.db"))
