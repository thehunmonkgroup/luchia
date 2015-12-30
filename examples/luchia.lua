-- Load all classes into a luchia object.
local luchia = require "luchia"
-- Create new document handler for the 'example' database.
local doc = luchia.document:new("example")
-- Simple document.
local contents = { hello = "world" }
-- Create new document.
local resp  = doc:create(contents)
-- Check for successful creation.
if doc:response_ok(resp) then
  -- Update document contents.
  contents = { hello = "world", foo = "bar" }
  -- Update document.
  doc:update(contents, resp.id, resp.rev)
end
