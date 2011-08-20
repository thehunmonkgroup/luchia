--[[
  Quick example of retrieving inline attachments.
]]

local luchia = require "luchia"

local log = luchia.log
local server = luchia.server
local request = luchia.request
local attachment = luchia.attachment

log:debug("Attaching file to new document...")

-- Grab a server object using the default connection configuration.
local srv = server:new()

local doc = {
  title = "Test attachment",
}

local params = {
  document = doc,
  file_name = "attachment.wav",
  file_path = "/tmp/attachment.wav",
  content_type = "audio/x-wav",
}


local att = attachment:new()
doc = att:add_attachment(params)

-- Build up the request parameters.
params = {
  method = "POST",
  path = "example/",
}
-- Grab a request object using the server object for communication.
local req = request:new(srv, params)
-- Execute the request.
local response = req:execute()

if response then
  -- Cycle through the returned table listing all document IDs.
  print("List of all document IDs:")
  for k, v in pairs(response) do
    print(k, v)
  end
end
