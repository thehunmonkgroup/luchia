-- Require the class.
local utilities = require "luchia.utilities"
-- Build a new utilities object.
local util = utilities:new()
-- Grab server version.
local response = util:version()
