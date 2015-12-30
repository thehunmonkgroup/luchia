-- Require the class.
local document = require "luchia.document"
-- Build a new document object.
local doc = document:new("example_database")
-- Create a new document.
local response = doc:create({hello = "world"})
