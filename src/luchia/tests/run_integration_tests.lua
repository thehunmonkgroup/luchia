--measure code coverage, if luacov is present
pcall(require, "luacov")
require "lunatest"
require "luchia.tests.common"

lunatest.suite("luchia.tests.integration.conf")
lunatest.suite("luchia.tests.integration.database")
lunatest.suite("luchia.tests.integration.document")
lunatest.suite("luchia.tests.integration.utilities")

lunatest.run()

