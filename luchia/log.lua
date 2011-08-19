--[[
  Provides basic configurable logging facilities.
]]

require "luchia.conf"
local log = luchia.conf.log

luchia.log = {}

function logging_exists()
  require("logging")
  require("logging.file")
  require("logging.console")
end

if pcall(logging_exists) and log.appender then
  if log.appender == "file" then
    luchia.log = logging.file(log.file, nil, log.format)
  else
    luchia.log = logging.console(log.format)
  end
  luchia.log:setLevel(logging[log.level])
else
  -- If logging is disabled, provide placeholder functions.
  local none = function() end
  luchia.log = {
    log = none,
    debug = none,
    info = none,
    warn = none,
    ["error"] = none,
    fatal = none,
    setLevel = none,
  }
end

return luchia.log

