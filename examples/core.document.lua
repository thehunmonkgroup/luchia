-- Require the class.
local document = require "luchia.core.document"
-- Build a new document object.
local doc = document:new({
  id = "document-id",
  document = {
    hello = "world",
  },
})
-- Add an attachment.
local response = doc:add_attachment(previously_created_attachment_object)
