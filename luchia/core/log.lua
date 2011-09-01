--- Provides logging facilities.
-- The lualogging module is required in order for logging to work properly,
-- as luchia merely leverages its functionality. If lualogging is not
-- installed, then logging will be disabled.
-- @author Chad Phillips
-- @copyright 2011 Chad Phillips

--- Log a message at the debug level.
-- @param self
-- @param message The message to log.
--   Note that for all logging methods listed, a function signature like
--   that of string.format() can be used, eg. <code>log:debug("hello world")
--   </code> and <code>log:debug("hello %s", "world")</code> are both valid
--   and will produce the same output.
-- @usage luchia.core.log:debug("debug message")
-- @class function
-- @name debug

--- Log a message at the info level.
-- @param self
-- @param message The message to log.
-- @usage luchia.core.log:info("info message")
-- @class function
-- @name info

--- Log a message at the warn level.
-- @param self
-- @param message The message to log.
-- @usage luchia.core.log:warn("warn message")
-- @class function
-- @name warn

--- Log a message at the error level.
-- @param self
-- @param message The message to log.
-- @usage luchia.core.log:error("error message")
-- @class function
-- @name error

--- Log a message at the fatal level.
-- @param self
-- @param message The message to log.
-- @usage luchia.core.log:fatal("fatal message")
-- @class function
-- @name fatal

local conf = require "luchia.conf"
local log = conf.log

luchia.core = luchia.core or {}
luchia.core.log = {}

function logging_exists()
  require("logging")
  require("logging.file")
  require("logging.console")
end

if pcall(logging_exists) and log.appender then
  if log.appender == "file" then
    luchia.core.log = logging.file(log.file, nil, log.format)
  else
    luchia.core.log = logging.console(log.format)
  end
  luchia.core.log:setLevel(logging[log.level])
else
  -- If logging is disabled, provide placeholder functions.
  local none = function() end
  luchia.core.log = {
    log = none,
    debug = none,
    info = none,
    warn = none,
    ["error"] = none,
    fatal = none,
    setLevel = none,
  }
end

return luchia.core.log

