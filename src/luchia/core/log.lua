--- Provides logging facilities.
-- @author Chad Phillips
-- @copyright 2011 Chad Phillips

--- Core logging class.
-- See the method documentation for more detail, here is a quick primer:</p>
-- <p><code>
-- -- Require the class.<br />
-- local logger = require "luchia.core.logger"<br />
-- -- Set up a shortcut to the logger function.<br />
-- local log = logger.logger<br />
-- -- Log something.<br />
-- log:info("Hello world!")<br />
-- </p></code>

--- Log a message at the debug level.
-- @param self
-- @param message
--   The message to log.
--   Note that for all logging methods listed, a function signature like
--   that of string.format() can be used, eg. <code>log:debug("hello world")
--   </code> and <code>log:debug("hello %s", "world")</code> are both valid
--   and will produce the same output.
-- @usage luchia.core.log.logger:debug("debug message")
-- @class function
-- @name debug

--- Log a message at the info level.
-- @param self
-- @param message
--   The message to log.
-- @usage luchia.core.log.logger:info("info message")
-- @class function
-- @name info

--- Log a message at the warn level.
-- @param self
-- @param message
--   The message to log.
-- @usage luchia.core.log.logger:warn("warn message")
-- @class function
-- @name warn

--- Log a message at the error level.
-- @param self
-- @param message
--   The message to log.
-- @usage luchia.core.log.logger:error("error message")
-- @class function
-- @name error

--- Log a message at the fatal level.
-- @param self
-- @param message
--   The message to log.
-- @usage luchia.core.log.logger:fatal("fatal message")
-- @class function
-- @name fatal

local logging = require("logging")
local conf = require "luchia.conf"

local _M = {}

--- Reconfigure the logger.
-- @param self
-- @param config
--   Configuration settings for the logger.
-- @usage luchia.core.logger:set_logger(config)
-- @class function
-- @see luchia.conf
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

