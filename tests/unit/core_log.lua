local lunatest = require "lunatest"
local assert_function = lunatest.assert_function
local assert_table = lunatest.assert_table

local log = require "luchia.core.log"

local tests = {}

function tests.setup()
   assert_table(log, "luchia.core.log")
end

function tests.test_log_log_function()
  assert_function(log.log, "log:log")
end

function tests.test_log_setlevel_function()
  assert_function(log.setLevel, "log:setLevel")
end

function tests.test_log_debug_function()
  assert_function(log.debug, "log:debug")
end

function tests.test_log_info_function()
  assert_function(log.info, "log:info")
end

function tests.test_log_warn_function()
  assert_function(log.warn, "log:warn")
end

function tests.test_log_error_function()
  assert_function(log.error, "log:error")
end

function tests.test_log_fatal_function()
  assert_function(log.fatal, "log:fatal")
end

return tests

