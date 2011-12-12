# Extend a source object with the properties of another object (shallow copy).
exports.extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

exports.visit = visit = (tree, { preorder, postorder, leaf, inorder }) ->
  preorder?(tree)
  if tree.children?.length
    for n in tree.children
      inorder?(tree)
      visit n, { preorder, postorder, leaf }
  else
    inorder?(tree)
    leaf?(tree)
  postorder?(tree)

exports.indent = indent = (n) ->
  new Array(n+1).join '  '

exports.last = (array, back) ->
  array[array.length - (back or 0) - 1]


exports.print_tree = print_tree = (tree) ->
  lvl = 0
  visit tree,
    preorder: (n) ->
      console.log 'preorder lvl', lvl
      console.log "#{indent(lvl)} head: #{n.head} op: #{n.op}"
      lvl++
    inorder: ->
      console.log 'inorder lvl', lvl
      lvl--

exports.trim = (s, chars) ->
  return String.prototype.trim.call(s) if not chars? and String.prototype.trim?      
  s.replace /^\s+|\s+$/g, ''

exports.escape_html = (s) ->
  s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
  .replace(/"/g, '&quot;').replace(/'/g, "&apos;")
  
exports.unescape_html = (s) ->
  s.replace(/&lt;/g, '<').replace(/&gt;/g, '>')
  .replace(/&quot;/g, '"').replace(/&apos;/g, "'").replace(/&amp;/g, '&')
  
exports.escape_reg_exp = (s) ->
  s.replace(/([-.*+?^${}()|\[\]\/\\])/g, '\\$1');

exports.indent = (n, s = '  ') ->
  return Array(n+1).join(s)
  
exports.unwrap = unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/

exports.jison_dsl = (patternString, action, options) ->
  patternString = patternString.replace /\s{2,}/g, ' '
  return [patternString, '$$ = $1;', options] unless action
  action = if match = unwrap.exec action then match[1] else "(#{action}())"
  action = action.replace /\bnew /g, '$&yy.'
  action = action.replace /\b(?:Block\.wrap|extend)\b/g, 'yy.$&'
  [patternString, "$$ = #{action};", options]

exports.peek = (arr) ->
  arr[arr.length-1]

# *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 
# *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 
# 
# Underscore.coffee pieces
# Included here to reduce dependency
# 
# *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 
# *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** 

nativeIsArray = Array.isArray
nativeForEach = Array.prototype.forEach
nativeReduce = Array.prototype.reduce

bind = (func, obj) ->
  args = rest arguments, 2
  -> func.apply obj or root, args.concat arguments

rest = (array, index, guard) ->
    slice.call(array, if isUndefined(index) or guard then 1 else index)

isUndefined = (obj) -> typeof obj is 'undefined'
isNumber = (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
identity = (value) -> value
isArray = nativeIsArray or (obj) -> !!(obj and obj.concat and obj.unshift and not obj.callee)

each = (obj, iterator, context) ->
  try
    if nativeForEach and obj.forEach is nativeForEach
      obj.forEach iterator, context
    else if isNumber obj.length
      iterator.call context, obj[i], i, obj for i in [0...obj.length]
    else
      iterator.call context, val, key, obj  for own key, val of obj
  catch e
    throw e if e isnt breaker
  obj

reduce = (obj, iterator, memo, context) ->
  if nativeReduce and obj.reduce is nativeReduce
    iterator = bind iterator, context if context
    return obj.reduce iterator, memo
  each obj, (value, index, list) ->
    memo = iterator.call context, memo, value, index, list
  memo
  
memoize = (func, hasher) ->
  memo = {}
  hasher or= identity
  ->
    key = hasher.apply this, arguments
    return memo[key] if key of memo
    memo[key] = func.apply this, arguments
    

exports.flatten = flatten = (array) ->
  reduce array, (memo, value) ->
    return memo.concat(flatten(value)) if isArray value
    memo.push value
    memo
  , []