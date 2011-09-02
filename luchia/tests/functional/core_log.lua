require "luchia.core.log"

local tests = {}

function tests.core_log_exists()
   assert_table(luchia, "luchia")
   assert_table(luchia.core, "luchia.core")
   assert_table(luchia.core.log, "luchia.core.log")
end

function tests.test_log_log_function()
  tests.core_log_exists()
  assert_function(luchia.core.log.log, "luchia.core.log:log")
end

function tests.test_log_setlevel_function()
  tests.core_log_exists()
  assert_function(luchia.core.log.setLevel, "luchia.core.log:setLevel")
end

function tests.test_log_debug_function()
  tests.core_log_exists()
  assert_function(luchia.core.log.debug, "luchia.core.log:debug")
end

function tests.test_log_info_function()
  tests.core_log_exists()
  assert_function(luchia.core.log.info, "luchia.core.log:info")
end

function tests.test_log_warn_function()
  tests.core_log_exists()
  assert_function(luchia.core.log.warn, "luchia.core.log:warn")
end

function tests.test_log_error_function()
  tests.core_log_exists()
  assert_function(luchia.core.log.error, "luchia.core.log:error")
end

function tests.test_log_fatal_function()
  tests.core_log_exists()
  assert_function(luchia.core.log.fatal, "luchia.core.log:fatal")
end

return tests

