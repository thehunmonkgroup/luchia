--[[
  Quick example of retrieving all docs.
]]

local luchia = require "luchia"

local log = luchia.log
local server = luchia.server

log:debug("Retrieving all docs...")

-- Grab a server object using the default connection configuration.
local srv = server:new()

-- Build up the request parameters.
local params = {
  path = "example/_all_docs",
  query_parameters = {
    include_docs = "true",
  },
}
-- Execute the request.
local response = srv:request(params)

if response then
  -- Cycle through the returned table listing all document IDs.
  print("List of all document IDs:")
  for _, doc in ipairs(response.rows) do
    print(doc.id)
  end
end
