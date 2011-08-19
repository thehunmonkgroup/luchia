--[[
  Provides basic configurable logging facilities.
]]

require "luchia.conf"
local log = luchia.conf.log

luchia.log = {}
if log.enabled then
  require("logging")
  if log.appender == "file" then
    require("logging.file")
    luchia.log = logging.file(log.file, nil, log.format)
  else
    require("logging.console")
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

