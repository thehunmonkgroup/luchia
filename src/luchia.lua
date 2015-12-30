--- Bootstrap file for the entire package.
--
-- Loading this file loads all classes in the package. This is for convenience
-- only, as all classes can be loaded and used separately.
--
-- See the @{luchia.lua} example for more detail.
--
-- @module luchia
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

local _M = {}

_M.conf = require "luchia.conf"
_M.core = {}
_M.core.log = require "luchia.core.log"
_M.core.server = require "luchia.core.server"
_M.core.document = require "luchia.core.document"
_M.core.attachment = require "luchia.core.attachment"
_M.database = require "luchia.database"
_M.document = require "luchia.document"
_M.utilities = require "luchia.utilities"

return _M
