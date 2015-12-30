# Introduction

## Overview

Luchia provides both low-level and high-level access to <a target="X"
href="http://couchdb.apache.org">CouchDB</a>, using an object-oriented
approach.

All of the basic operations are supported, including:

 * CRUD operations on databases.
 * CRUD operations on documents.
 * CRUD operations on attachments (both inline and standalone).
 * uuid generation (server side).
 * Various utility functions.

Low-level access is provided by the core modules, while higher-level
access is provided by the database, document, and utilities modules.
The package also includes <code>luchia_get</code>, a command-line script that can be
used to perform simple GET requests to the default server.

## Configuration

See @{luchia.conf} for configuration details.

## Usage

In general, avoid using the core classes directly unless an operation is
needed that isn't supported by the higher-level modules. Basic examples
are provided in the <code>examples</code> directory, and more detailed
examples in the online documentation.
