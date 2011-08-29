--- Global configuration file.
-- @author Chad Phillips
-- @copyright 2011 Chad Phillips

--- Global configuration file.
module("luchia.conf")

default = {}

--- The default server.
-- When no server object is created specifically, the default server is used.
-- @field protocol The protocol to use, currently only "http" is allowed.
-- @field host The host name, eg. "localhost" or "www.example.com".
-- @field port The port to use, eg. "5984".
-- @class table
-- @name default.server
default.server = {}
default.server.protocol = "http"
default.server.host = "localhost"
default.server.port = "5984"

--- Logging options.
-- The lualogging package must be installed to use the logging facilities.
-- @field appender Where to log messages. Must be one of "console", "file",
-- false (disables logging).
-- @field level Minimum level of messages to log. Must be one of "DEBUG",
-- "INFO", "WARN", "ERROR", "FATAL"
-- @field format String format for logged messages.  Tokens are %date, %level,
-- %message, eg. "%level %message\n".
-- @field file Full path of a file to log to if appender is set to "file", eg.
-- "/tmp/luchia.log".
-- @class table
-- @name log
log = {}
log.appender = "console"
log.level = "DEBUG"
log.format = "%level %message\n"
log.file = "/tmp/luchia.log"
