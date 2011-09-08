--measure code coverage, if luacov is present
pcall(require, "luacov")
require "lunatest"
require "luchia.tests.common"

lunatest.suite("luchia.tests.unit.core_log")
lunatest.suite("luchia.tests.unit.core_server")
lunatest.suite("luchia.tests.unit.core_attachment")
lunatest.suite("luchia.tests.unit.core_document")
lunatest.suite("luchia.tests.unit.database")
lunatest.suite("luchia.tests.unit.document")
lunatest.suite("luchia.tests.unit.utilities")

lunatest.run()
