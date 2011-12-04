#!/usr/bin/env coffee
CoffeeScript = require('coffee-script')
Smack  = require './Smack'
fs = require 'fs'
path = require 'path'
{ ok, equal, fail } = require 'assert'

console.log """
  ~|>
    p#status.block-message |alt: Bla Bla Bla| > div.clear-fix
  ~
    Upload Successful!
  |~
""", """
     
"""

