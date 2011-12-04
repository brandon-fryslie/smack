(function() {
  var Smack, runScripts;

  Smack = require('./Smack');

  Smack.require = require;

  Smack.eval = function(code, options) {
    return eval(Smack.compile(code, options));
  };

  Smack.run = function(code, options) {
    if (options == null) options = {};
    options.bare = true;
    return Function(Smack.compile(code, options))();
  };

  if (typeof window === "undefined" || window === null) return;

  Smack.load = function(url, callback) {
    var xhr;
    xhr = new (window.ActiveXObject || XMLHttpRequest)('Microsoft.XMLHTTP');
    xhr.open('GET', url, true);
    if ('overrideMimeType' in xhr) xhr.overrideMimeType('text/plain');
    xhr.onreadystatechange = function() {
      var _ref;
      if (xhr.readyState === 4) {
        if ((_ref = xhr.status) === 0 || _ref === 200) {
          Smack.run(xhr.responseText);
        } else {
          throw new Error("Could not load " + url);
        }
        if (callback) return callback();
      }
    };
    return xhr.send(null);
  };

  runScripts = function() {
    var execute, index, length, s, scripts, smack_blocks;
    scripts = document.getElementsByTagName('script');
    smack_blocks = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = scripts.length; _i < _len; _i++) {
        s = scripts[_i];
        if (s.type === 'text/smack') _results.push(s);
      }
      return _results;
    })();
    index = 0;
    length = smack_blocks.length;
    (execute = function() {
      var script;
      script = smack_blocks[index++];
      if ((script != null ? script.type : void 0) === 'text/Smack') {
        if (script.src) {
          return Smack.load(script.src, execute);
        } else {
          Smack.run(script.innerHTML);
          return execute();
        }
      }
    })();
    return null;
  };

  if (window.addEventListener) {
    addEventListener('DOMContentLoaded', runScripts, false);
  } else {
    attachEvent('onload', runScripts);
  }

}).call(this);
