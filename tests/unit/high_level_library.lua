local lunatest = require "lunatest"
local assert_table = lunatest.assert_table

local tests = {}

function tests.test_require_luchia_returns_valid_luchia_object()
  local luchia = require "luchia"
  assert_table(luchia.core.attachment, "luchia.core.attachment")
  assert_table(luchia.core.document, "luchia.core.document")
  assert_table(luchia.core.log, "luchia.core.log")
  assert_table(luchia.core.server, "luchia.core.server")
  assert_table(luchia.conf, "luchia.conf")
  assert_table(luchia.database, "luchia.database")
  assert_table(luchia.document, "luchia.document")
  assert_table(luchia.utilities, "luchia.utilities")
end

return tests

