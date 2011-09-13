--[[
  Quick example of adding an inline attachment to a document.
]]

require "luchia"

local log = luchia.core.log
local server = luchia.core.server
local document = luchia.core.document
local attachment = luchia.core.attachment

log:debug("Attaching file to new document...")

-- Grab a server object using the default connection configuration.
local srv = server:new()

-- Build the attachment.
local params = {
  file_path = "/tmp/attachment.wav",
  content_type = "audio/x-wav",
}
local att = attachment:new(params)

-- Create the document.
params = {
  document = {
    title = "Test attachment",
  },
}
local doc = document:new(params)

-- Attach the attachment.
if doc:add_attachment(att) then
  -- Build up the request parameters.
  params = {
    method = "POST",
    path = "example",
    data = doc,
  }
  -- Execute the request.
  local response = srv:request(params)
end
