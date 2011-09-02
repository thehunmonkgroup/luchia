require "lunatest"

lunatest.suite("functional.conf")
lunatest.suite("functional.core_log")
lunatest.suite("functional.core_server")
lunatest.suite("functional.core_attachment")
lunatest.suite("functional.core_document")
lunatest.suite("functional.database")
lunatest.suite("functional.document")
lunatest.suite("functional.utilities")

lunatest.run()
