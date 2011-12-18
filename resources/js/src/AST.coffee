
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
    @op = front_op
    
    if front_op is ' ' and rear_op is ' '
      @op = [':']
    else
      @op = []
      @op.push op for op in front_op.split(/\s/) when op isnt ''
      @op.push op for op in rear_op.split(/\s/) when op isnt ''
      @op[@op.length-1] = last(@op).replace ':', '' if @op.length > 1
    
  compile: (o) ->
    leaves = @zentag.leaves empty: yes
        
    last_node_idx = leaves.length-1
    
    # If there are no leaves, compile right now
    return @zentag.compile o if last_node_idx is -1
    
    placeholder_re = /~\|\$[0-9]+\:~/
    last_leaf_re   = ///~\|\$#{last_node_idx}\:~///
    populator_re = /~\|\$[a-zA-Z0-9_]+\:~/

    content = (c.compile(o) for c in @contents).join ''
                
    switch @op[0]
      when 'split'
        content = content.split @op[1]
        
        while content.length and leaves[last_node_idx]?
          leaves[last_node_idx].set_content trim content.pop()
          last_node_idx--
      when 'wrap'
        children = @zentag.tag.root.children
        template = last children
        for c in content.split @op[1]
          children.push template.copy trim c        
        children.splice 0, 1
      when ':'
        leaves[last_node_idx].set_content content
    
    if o.indent
      o.indent_lvl = 0
    
    @zentag.compile o
    
exports.ZenTag = class ZenTag extends Node
  
  children: ['tag']
  
  constructor: (tag) ->
    @tag = Zen.nodes tag

  leaves: (o) ->
    @tag.leaves(o)

  compile: (o) ->
    @tag.compile o
    
exports.Literal = class Literal extends Node
    
  constructor: (@value) ->
    
  compile: -> "#{@value}"

