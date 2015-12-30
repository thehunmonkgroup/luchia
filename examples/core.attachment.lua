-- Require the class.
local attachment = require "luchia.core.attachment"
-- Build a new attachment object.
local att = attachment:new({
  file_path = "/tmp/attachment.txt",
  content_type = "text/plain",
  file_name = "afile",
})
-- Base64 encode the file data.<br />
local encoded_data = att:base64_encode_file()
