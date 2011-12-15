
Zen = require './Zen'
{trim, visit, flatten, print_tree, last} = require './Helper'

Node = class Node
  
  constructor: (@children = []) ->
  
  push: (node) -> @children.push node; this

exports.Body = class Body extends Node
    
  compile: (o) ->
    o ?= {}
    (n.compile(o) for n in @children).join ''

exports.SmackBlock = class SmackBlock extends Node

  constructor: (front_op, @zentag, @contents, rear_op) ->
    if front_op is ' '
      @op = if rear_op is ' ' then '>' else rear_op.split ' '
    else
      @op = front_op.split ' '
    
  compile: (o) ->
    
    leaves = @zentag.leaves()
        
    last_node_idx = leaves.length-1
    
    return @zentag.compile o if last_node_idx is -1
    
    placeholder_re = /~\|\$[0-9]+\:~/
    last_leaf_re   = ///~\|\$#{last_node_idx}\:~///
    populator_re = /~\|\$[a-zA-Z0-9_]+\:~/

    content = (c.compile() for c in @contents).join ''
                
    switch @op[0]
      when 'split'
        
        content = content.split @op[1].replace('>','')
        
        while content.length and leaves[last_node_idx]?
          leaves[last_node_idx].set_content trim content.pop()
          last_node_idx--
        
      when '>'
        leaves[last_node_idx].set_content content

    @zentag.compile o
    
exports.ZenTag = class ZenTag extends Node
  
  children: ['tag']
  
  constructor: (tag) ->
    @tag = Zen.nodes tag

  leaves: ->
    @tag.leaves()

  compile: (o) ->
    @tag.compile o
    
exports.Literal = class Literal extends Node
    
  constructor: (@value) ->
    
  compile: -> "#{@value}"

