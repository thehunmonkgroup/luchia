# Luchia
Lua API for CouchDB (http://couchdb.apache.org).

 * Compatible with Lua 5.1, 5.2, 5.3
 * 100% unit test coverage

## Installation:

It is recommended to install the LuaRocks (http://luarocks.org) package
manager, as all required and optional dependencies are easy to install via this
method.

####  Requires
 * lua-cjson
 * lualogging
 * luasocket

#### Optional
 * stdlib (prettier output for luchia_get)
 * ldoc (to generate local documentation)
 * lunatest (to run unit tests)
 * luacov (to view unit test coverage)

With LuaRocks, simply run:

    luarocks install luchia

For manual installation, copy luchia.lua and the luchia directory from the
source directory, and put them somewhere in your Lua package path.

## Documentation

See the [online manual](http://thehunmonkgroup.github.com/luchia/topics/INTRODUCTION.md.html).

For local documentation, all documentation is inline, but is
[ldoc](https://github.com/stevedonovan/LDoc) compatible.

#### To generate HTML documentation locally

 * Checkout this repository
 * Install ldoc <code>luarocks install ldoc</code>
 * In the root directory of the repository, run:

    ldoc .

## Support
The issue tracker for this project is provided to file bug reports, feature
requests, and project tasks -- support requests are not accepted via the issue
tracker. For all support-related issues, including configuration, usage, and
training, consider hiring a competent consultant.

## Unit tests

Luchia has full unit test coverage. They can be run with:

    cd /path/to/luchia/tests
    lua run_unit_tests.lua -v


## Integration tests

The higher-level Luchia classes (luchia.database, luchia.document,
luchia.utilities) have a full integration test suite. To run it, make sure
that the default server settings in luchia.conf point to a valid, running
CouchDB instance with full administrative access, and run:

    cd /path/to/luchia/tests
    lua run_integration_tests.lua -v

