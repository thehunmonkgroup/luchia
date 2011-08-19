module(...)

default = {}

-- DEFAULT SERVER.
default.server = {}
default.server.protocol = "http"
default.server.host = "localhost"
default.server.port = "5984"

-- LOGGING OPTIONS
-- The lualogging package must be installed to use the logging facilities.
log = {}

-- Where to log messages.  Must be one of:
--   "console"
--   "file"
--   false (disables logging)
log.appender = "console"

-- Minimum level of messages to log.  Must be one of:
--   "DEBUG"
--   "INFO"
--   "WARN"
--   "ERROR"
--   "FATAL"
log.level = "DEBUG"

-- String format for logged messages.  Tokens are:
--   %date
--   %level
--   %message
log.format = "%level %message\n"

-- File to log to.
log.file = "/tmp/luchia.log"
