--- Bootstrap file for the entire package.
-- Loading this file loads all classes in the package. This is for convenience
-- only, as all classes can be loaded and used separately.
-- @author Chad Phillips
-- @copyright 2011 Chad Phillips

require "luchia.conf"
require "luchia.core.log"
require "luchia.core.server"
require "luchia.core.document"
require "luchia.core.attachment"
require "luchia.database"
require "luchia.document"
require "luchia.utilities"

--- Summary of the project, start the documentation journey here.
-- <h3>Overview</h3>
-- <p>Luchia provides both low-level and high-level access to <a target="X"
-- href="http://couchdb.apache.org">CouchDB</a>, using an object-oriented
-- approach.</p>
-- <p>All of the basic operations are supported, including:
-- <ul>
--   <li>CRUD operations on databases.</li>
--   <li>CRUD operations on documents.</li>
--   <li>CRUD operations on attachments (both inline and standalone).</li>
--   <li>uuid generation (server side).</li>
--   <li>Various utility functions.</li>
-- </ul></p>
-- <p>Low-level access is provided by the 'core' modules, while higher-level
-- access is provided by the database, document, and utilities modules.</p>
-- <p>The package also includes luchia.sh, a command-line script that can be
-- used to perform simple GET requests to the default server.</p>
-- <h3>Configuration</h3>
-- <p>See <a href="luchia.conf.html">luchia.conf</a> for configuration
-- details.</p>
-- <h3>Usage</h3>
-- <p>In general, avoid using the core classes directly unless an operation is needed that isn't supported by the higher-level modules.</p>
-- <p>Detailed examples are provided in relevant module documentation, but
-- here's a quick primer:<p/>
-- <p><code>
-- -- Load all modules.<br />
-- require "luchia"<br />
-- -- Create new document handler for the 'example' database.<br />
-- local doc = luchia.document:new("example")<br />
-- -- Simple document.<br />
-- local contents = { hello = "world" }<br />
-- -- Create new document.<br />
-- local resp  = doc:create(contents)<br />
-- -- Check for successful creation.<br />
-- if doc:response_ok(resp) then<br />
-- &nbsp;&nbsp;-- Update document contents.<br />
-- &nbsp;&nbsp;contents = { hello = "world", foo = "bar" }<br />
-- &nbsp;&nbsp;-- Update document.<br />
-- &nbsp;&nbsp;doc:update(contents, resp.id, resp.rev)<br />
-- end
-- </code></p>
module("luchia")

