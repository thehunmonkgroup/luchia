--- Core logging class.
--
-- See the @{core.log.lua} example for more detail.
--
-- @module luchia.core.log
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

local logging = require("logging")
local conf = require "luchia.conf"

local _M = {}

--- The logging class.
--
-- Wrapper to <a href="http://neopallium.github.io/lualogging/manual.html">lualogging</a> class.
--
-- @usage logger:debug("debug message")
-- @see core.log.lua
_M.logger = {}

--- Reconfigure the logger.
-- @param config
--   Configuration settings for the logger.
-- @usage luchia.core.log:set_logger(config)
-- @see luchia.conf
function _M:set_logger(config)
  config = config or conf.log
  if config.appender == "file" then
    local file = require("logging.file")
    self.logger = file(config.file, nil, config.format)
  else
    local console = require("logging.console")
    self.logger = console(config.format)
  end
  self.logger:setLevel(logging[config.level])
end

_M:set_logger()

return _M

