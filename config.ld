project = "Luchia"
description = "Lua API for CouchDB"
package = "luchia"
title = "Luchia documentation"
file = {
  "./src",
  "./src/luchia_get",
}
dir = "./documentation"
topics = {
  "./src/INTRODUCTION.md"
}
format = "markdown"
all = true
examples = "./examples"
wrap = true
no_space_before_args = true
style = "!fixed"
-- This is a custom setting not currently available in LDoc, see
-- https://github.com/stevedonovan/LDoc/pull/223
--custom_css = "ldoc.custom.css"

-- vi: ft=lua
