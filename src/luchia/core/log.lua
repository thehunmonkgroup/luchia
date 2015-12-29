--- Provides logging facilities.
-- @author Chad Phillips
-- @copyright 2011 Chad Phillips

--- Log a message at the debug level.
-- @param self
-- @param message
--   The message to log.
--   Note that for all logging methods listed, a function signature like
--   that of string.format() can be used, eg. <code>log:debug("hello world")
--   </code> and <code>log:debug("hello %s", "world")</code> are both valid
--   and will produce the same output.
-- @usage luchia.core.log:debug("debug message")
-- @class function
-- @name debug

--- Log a message at the info level.
-- @param self
-- @param message
--   The message to log.
-- @usage luchia.core.log:info("info message")
-- @class function
-- @name info

--- Log a message at the warn level.
-- @param self
-- @param message
--   The message to log.
-- @usage luchia.core.log:warn("warn message")
-- @class function
-- @name warn

--- Log a message at the error level.
-- @param self
-- @param message
--   The message to log.
-- @usage luchia.core.log:error("error message")
-- @class function
-- @name error

--- Log a message at the fatal level.
-- @param self
-- @param message
--   The message to log.
-- @usage luchia.core.log:fatal("fatal message")
-- @class function
-- @name fatal

local logging = require("logging")
local conf = require "luchia.conf"

local _M = {}

_M.set_logger = function(self, config)
  config = config or conf.log
  if config.appender == "file" then
    local file = require("logging.file")
    _M.logger = file(config.file, nil, config.format)
  else
    local console = require("logging.console")
    _M.logger = console(config.format)
  end
  _M.logger:setLevel(logging[config.level])
end

_M:set_logger()

return _M

