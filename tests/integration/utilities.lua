local lunatest = require "lunatest"
local assert_equal = lunatest.assert_equal
local assert_table = lunatest.assert_table

local utilities = require "luchia.utilities"

local tests = {}
local util

function tests.setup()
  util = utilities:new()
  assert_table(util, "Unable to create utilities server")
end

function tests.teardown()
  util = nil
end

function tests.test_version()
  local server = require "luchia.core.server"
  local srv = server:new()
  local info = srv:request()
  local version = util:version()
  assert_equal(info.version, version, "Unable to get matching version information")
end

function tests.test_get_default_cluster_node()
  local default = util:get_default_cluster_node()
  assert_equal("string", type(default), "Unable to get default cluster node")
end

function tests.test_membership()
  local nodes = util:membership()
  assert_table(nodes.cluster_nodes, "Unable to get node membership info")
end

function tests.test_config_default_node()
  local config = util:config()
  assert_table(config.httpd, "Unable to get default node config")
end

function tests.test_config_passed_node()
  local node = util:get_default_cluster_node()
  local config = util:config(node)
  assert_table(config.httpd, "Unable to get passed node config")
end

function tests.test_stats_default_node()
  local stats = util:stats()
  assert_table(stats.couchdb, "Unable to get default node stats")
end

function tests.test_stats_passed_node()
  local node = util:get_default_cluster_node()
  local stats = util:stats(node)
  assert_table(stats.couchdb, "Unable to get passed node stats")
end

function tests.test_active_tasks()
  local active_tasks = util:active_tasks()
  assert_table(active_tasks, "Unable to get active tasks")
end

return tests

