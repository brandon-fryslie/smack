(function() {
  var Parser, alt, alternatives, grammar, name, o, operators, token, tokens, unwrap;

  Parser = require('jison').Parser;

  unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/;

  o = function(patternString, action, options) {
    var match;
    patternString = patternString.replace(/\s{2,}/g, ' ');
    if (!action) return [patternString, '$$ = $1;', options];
    action = (match = unwrap.exec(action)) ? match[1] : "(" + action + "())";
    action = action.replace(/\bnew /g, '$&yy.');
    action = action.replace(/\b(?:Block\.wrap|extend)\b/g, 'yy.$&');
    return [patternString, "$$ = " + action + ";", options];
  };

  grammar = {
    Root: [
      o('', function() {
        return new Body;
      }), o('Body')
    ],
    Body: [
      o('Expression', function() {
        return new Body([$1]);
      }), o('Body Expression', function() {
        return $1.push($2);
      })
    ],
    Expression: [o('SmackBlock')],
    SmackBlock: [
      o('OPENTAG SMACK_OPERATOR SmackTagConfig MIDTAG LITERAL SMACK_OPERATOR CLOSETAG', function() {
        return new SmackBlock($2, $3, $5, $6);
      }), o('OPENTAG SMACK_OPERATOR LITERAL MIDTAG SmackTagConfig SMACK_OPERATOR CLOSETAG', function() {
        return new SmackBlock($2, $5, $3, $6);
      })
    ],
    SmackTagConfig: [o('ZenTag')],
    ZenTag: [
      o('HtmlTag', function() {
        return new ZenTag($1);
      }), o('ZenTag ZEN_OPERATOR HtmlTag', function() {
        $1.tags.push({
          op: $2,
          tag: $3
        });
        return $1;
      })
    ],
    HtmlTag: [
      o('ELEMENT AbbreviatedAttributeList AttributeList', function() {
        return new HtmlTag($1, $2, $3);
      })
    ],
    AbbreviatedAttributeList: [
      o('', function() {
        return [];
      }), o('AbbreviatedAttributes', function() {
        return $1;
      })
    ],
    AbbreviatedAttributes: [
      o('ABBREVIATED_ATTRIBUTE', function() {
        return [$1];
      }), o('AbbreviatedAttributes ABBREVIATED_ATTRIBUTE', function() {
        return $1.concat($2);
      })
    ],
    AttributeList: [
      o('', function() {
        return [];
      }), o('ATTR_LIST_OPEN Attributes ATTR_LIST_CLOSE', function() {
        return $2;
      })
    ],
    Attributes: [
      o('ATTRIBUTE', function() {
        return [$1];
      }), o('Attributes ATTRIBUTE', function() {
        return $1.concat($2);
      })
    ]
  };

  operators = [];

  tokens = [];

  for (name in grammar) {
    alternatives = grammar[name];
    grammar[name] = (function() {
      var _i, _j, _len, _len2, _ref, _results;
      _results = [];
      for (_i = 0, _len = alternatives.length; _i < _len; _i++) {
        alt = alternatives[_i];
        _ref = alt[0].split(' ');
        for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
          token = _ref[_j];
          if (!grammar[token]) tokens.push(token);
        }
        _results.push(alt);
      }
      return _results;
    })();
  }

  exports.parser = new Parser({
    tokens: tokens.join(' '),
    bnf: grammar,
    operators: operators.reverse(),
    startSymbol: 'Root'
  });

}).call(this);
