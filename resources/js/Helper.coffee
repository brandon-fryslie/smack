

exports._h =
  escape_html: (s) -> s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
                          .replace(/"/g, '&quot;').replace(/'/g, "&apos;")
  
  unescape_html: (s) -> s.replace(/&lt;/g, '<').replace(/&gt;/g, '>')
                          .replace(/&quot;/g, '"').replace(/&apos;/g, "'").replace(/&amp;/g, '&')
  
  escape_reg_exp: (s) -> s.replace(/([-.*+?^${}()|\[\]\/\\])/g, '\\$1');
  
  trim: (s, chars) ->
    return String.prototype.trim.call(str) if not chars? and String.prototype.trim?      
    s.replace /^\s+|\s+$/g, ''

  join: (arr, char = '') ->
    throw "_h.join: not an array, brah-man!" if arr not instanceof Array
    arr.join(char)
  
  indent: (n, s = '  ') -> return Array(n+1).join(s)