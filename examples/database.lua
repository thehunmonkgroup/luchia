-- Require the class.
local database = require "luchia.database"
-- Build a new database object.
local db = database:new()
-- Create a new database.
local response = db:create("example_database")
