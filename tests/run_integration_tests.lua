--measure code coverage, if luacov is present
pcall(require, "luacov")
local lunatest = require "lunatest"

lunatest.suite("integration.conf")
lunatest.suite("integration.database")
lunatest.suite("integration.document")
lunatest.suite("integration.utilities")

lunatest.run()

