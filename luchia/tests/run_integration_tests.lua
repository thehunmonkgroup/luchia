--measure code coverage, if luacov is present
pcall(require, "luacov")
require "lunatest"
require "luchia.tests.common"

lunatest.suite("luchia.tests.integration.conf")

lunatest.run()

