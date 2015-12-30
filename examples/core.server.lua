-- Require the class.
local server = require "luchia.core.server"
-- Build a new server object.
local srv = server:new({
  connection = {
    protocol = "http",
    host = "www.example.com",
    port = "5984",
  },
})
-- Make a request.
local response = srv:request({
  path = "/",
})
