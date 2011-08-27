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
    local response = self.server:request(params)
    return response
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
    local method = "POST"
    if id then
      method = "PUT"
    else
      id = ""
    end
    local doc = make_document(self, document, id)
    local query_parameters = nil
    return document_call(self, method, id, query_parameters, doc)
  else
    log:error([[Document is required]])
  end
end

function update(self, document, id, rev)
  if not document then
    log:error([[Document is required]])
  elseif not id then
    log:error([[ID is required]])
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

function add_standalone_attachment(self, file_path, content_type, file_name, id, rev)
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
end

function response_ok(self, response)
  return self.server:response_ok(response)
end

