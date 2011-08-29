--- Bootstrap file for the entire package.
-- @author Chad Phillips
-- @copyright 2011 Chad Phillips

require "luchia.conf"
require "luchia.core.log"
require "luchia.core.server"
require "luchia.core.document"
require "luchia.core.attachment"
require "luchia.database"
require "luchia.document"
require "luchia.utilities"

--- Bootstrap file for the entire package.
-- Loading this file loads all classes in the package. This is for convenience
-- only, as all classes can be loaded and used separately.
module("luchia")

