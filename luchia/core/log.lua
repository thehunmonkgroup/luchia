--- Provides logging facilities.
-- @author Chad Phillips
-- @copyright 2011 Chad Phillips

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

