require "lunatest"
require "luchia.tests.common"

lunatest.suite("luchia.tests.functional.conf")
lunatest.suite("luchia.tests.functional.core_log")
lunatest.suite("luchia.tests.functional.core_server")
lunatest.suite("luchia.tests.functional.core_attachment")
lunatest.suite("luchia.tests.functional.core_document")
lunatest.suite("luchia.tests.functional.database")
lunatest.suite("luchia.tests.functional.document")
lunatest.suite("luchia.tests.functional.utilities")

lunatest.run()
