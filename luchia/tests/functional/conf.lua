local conf = require "luchia.conf"
local tests = {}

function tests.valid_default_server_table()
  assert_table(conf.default, "conf.default")
  assert_table(conf.default.server, "conf.default.server,")
end

function tests.test_default_server_protocol()
  tests.valid_default_server_table()
  assert_equal("http", conf.default.server.protocol, "conf.default.server.protocol,")
end

function tests.test_default_server_host()
  tests.valid_default_server_table()
  assert_match("^[%a%.-_]+$", conf.default.server.host, "conf.default.server.host")
end

function tests.test_default_server_port()
  tests.valid_default_server_table()
  local port = tonumber(conf.default.server.port)
  assert_gte(1, port, "default.server.port")
  assert_lte(65536, port, "default.server.port")
end

function tests.valid_log_table()
  assert_table(conf.log, "conf.log")
end

function tests.test_log_appender()
  tests.valid_log_table()
  if conf.log.appender then
    if conf.log.appender ~= "console" and conf.log.appender ~= "file" then
      fail("Expected value 'console' or 'file' - conf.log.appender", true)
    end
  end
end

function tests.test_log_level()
  tests.valid_log_table()
  if conf.log.level ~= "DEBUG" and conf.log.level ~= "INFO" and conf.log.level ~= "WARN" and conf.log.level ~= "ERROR" and conf.log.level ~= "FATAL" then
    fail("Expected value 'DEBUG' or 'INFO' or 'WARN' or 'ERROR' or 'FATAL' - conf.log.level", true)
  end
end

return tests

