--[[
  Methods for working with documents.
]]

require "luchia.conf"
local log = require "luchia.core.log"
local server = require "luchia.core.server"
local document = require "luchia.core.document"
local attachment = require "luchia.core.attachment"
local string = require "string"

local setmetatable = setmetatable

module(...)

function new(self, database, params)
  local params = params or {}
  if database then
    local document = {}
    document.database = database
    document.server = params.server or server:new()
    setmetatable(document, self)
    self.__index = self
    log:debug(string.format(string.format([[New document handler to database '%s']], document.database)))
    return document
  else
    log:error([[Database name is required]])
  end
end

local function document_call(self, method, path, query_parameters, data)
  if path then
    local params = {
      method = method,
      path = self.database .. "/" .. path,
      query_parameters = query_parameters,
      data = data,
    }
    local response, response_code, headers, status = self.server:request(params)
    return response, response_code, headers, status
  else
    log:error([[Path is required]])
  end
end

local function make_document(self, data, id, rev)
  params = {
    document = data,
    id = id,
    rev = rev,
  }
  local doc = document:new(params)
  return doc
end

local function make_attachment(self, file_name, file_path, content_type)
  local params = {
    file_name = file_name,
    file_path = file_path,
    content_type = content_type,
  }
  local att = attachment:new(params)
  return att
end

function list(self, query_parameters)
  return document_call(self, "GET", "_all_docs", query_parameters)
end

function retrieve(self, id, query_parameters)
  return document_call(self, "GET", id, query_parameters)
end

function create(self, document, id)
  if document then
    -- CouchDB documentation advises to not use POST if possible, instead
    -- to use PUT with a newly generated id.
    if not id then
      local uuids = self.server:uuids()
      id = uuids[1]
    end
    local doc = make_document(self, document, id)
    local query_parameters = nil
    return document_call(self, "PUT", id, query_parameters, doc)
  else
    log:error([[Document is required]])
  end
end

function update(self, document, id, rev)
  if not document then
    log:error([[document is required]])
  elseif not id then
    log:error([[id is required]])
  elseif not rev then
    log:error([[rev is required]])
  else
    local doc = make_document(self, document, id, rev)
    local query_parameters = nil
    return document_call(self, "PUT", id, query_parameters, doc)
  end
end

function copy(self, id, destination)
  if not id then
    log:error([[id is required]])
  elseif not destination then
    log:error([[destination is required]])
  else
    local params = {
      method = "COPY",
      path = self.database .. "/" .. id,
      headers = {
        destination = destination
      },
    }
    local response = self.server:request(params)
    return response
  end
end

function delete(self, id, rev)
  if rev then
    local params = {
      rev = rev,
    }
    return document_call(self, "DELETE", id, params)
  else
    log:error([[rev is required]])
  end
end

function info(self, id)
  if id then
    local response, response_code, headers = document_call(self, "HEAD", id)
    return headers
  else
    log:error([[id is required]])
  end
end

function current_revision(self, id)
  if id then
    local headers = self:info(id)
    return headers.etag
  else
    log:error([[id is required]])
  end
end

local function build_attachment(self, file_path, content_type, file_name)
  if not file_path then
    log:error([[file_path is required]])
  elseif not content_type then
    log:error([[content_type is required]])
  else
    local params = {
      file_name = file_name,
      file_path = file_path,
      content_type = content_type,
    }
    local att = attachment:new(params)
    return att
  end
end

function add_standalone_attachment(self, file_path, content_type, file_name, id, rev)
  local att = build_attachment(self, file_path, content_type, file_name)
  if att then
    if not id then
      id = att.file_name
    end
    -- Build up the request parameters.
    params = {
      method = "PUT",
      path = string.format([[%s/%s/%s]], self.database, id, att.file_name),
      data = att,
    }
    if rev then
      params.query_parameters = {
        rev = rev,
      }
    end
    local response = self.server:request(params)
    return response
  end
end

function add_inline_attachment(self, file_path, content_type, file_name, document, id, rev)
  local att = build_attachment(self, file_path, content_type, file_name)
  if att then
    -- Attach the attachment.
    local doc = make_document(self, document, id, rev)
    if doc and doc:add_attachment(att) then
      -- Use update/create methods from this class. They expect a raw document
      -- table instead of a document object, so extract it out.
      if rev then
        self:update(doc.document, id, rev)
      else
        self:create(doc.document, id)
      end
    else
      log:error([[Error adding attachment]])
    end
  end
end

function delete_attachment(self, attachment, id, rev)
  if not attachment then
    log:error([[attachment is required]])
  elseif not id then
    log:error([[id is required]])
  elseif not rev then
    log:error([[rev is required]])
  else
    local path = string.format([[%s/%s]], id, attachment)
    local params = {
      rev = rev,
    }
    return document_call(self, "DELETE", path, params)
  end
end

function response_ok(self, response)
  return self.server:response_ok(response)
end

