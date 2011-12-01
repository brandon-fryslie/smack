(function() {
  var AttrAbbr, AttrKey, AttrList, AttrVal, CloseTagRE, CloseTagTest, Element, Literal, MidtagRE, MidtagTest, OpenTagRE, OpenTagTest, SmackAliasRE, SmackLexer, SmackOperatorRE, SmackOperatorTest, SmackVariableRE, Whitespace, ZenOperator, k, lex, ok, t, v, _, _ref;

  SmackLexer = (function() {

    function SmackLexer() {}

    SmackLexer.prototype.TEST = {
      MAIN: 0,
      OPENTAG: 0,
      WHITESPACE: 0,
      FOR_TOKENS: 0,
      ELEMENT: 0,
      LITERAL: 0
    };

    SmackLexer.prototype.tokenize = function(code) {
      var i, open_tag_idx, _ref, _ref2, _ref3;
      if ((_ref = this.TEST) != null ? _ref.MAIN : void 0) {
        console.log("tokenizing code: " + code);
      }
      this.code = code.replace(/\r/g, '');
      this.line = 0;
      this.tokens = [];
      i = 0;
      while (this.chunk = this.code.slice(i)) {
        if ((_ref2 = this.TEST) != null ? _ref2.MAIN : void 0) {
          console.log("main@in_config(): " + (this.in_config()));
        }
        open_tag_idx = function(token, i) {
          if (token[0] === 'OPENTAG') {
            return i;
          } else {
            return token;
          }
        };
        this.for_tokens(function() {
          return open_tag_idx;
        });
        if ((_ref3 = this.TEST) != null ? _ref3.MAIN : void 0) {
          console.log(this.chunk);
        }
        i += this.OpenTag() || this.SmackOperator() || this.Midtag() || this.CloseTag() || this.Element() || this.AttributeAbbreviation() || this.AttributeList() || this.ZenOperator() || this.Literal() || this.Whitespace() || this.LexerError();
      }
      this.closeTags();
      return this.tokens;
    };

    SmackLexer.prototype.closeTags = function() {
      return '</div>';
    };

    SmackLexer.prototype.for_tokens = function(fn) {
      var i, res, store, _ref, _ref2, _results;
      var _this = this;
      if ((_ref = this.TEST) != null ? _ref.FOR_TOKENS : void 0) {
        console.log('@for_tokens:');
      }
      if ((_ref2 = this.TEST) != null ? _ref2.FOR_TOKENS : void 0) {
        console.log(this.tokens);
      }
      store = null;
      res = null;
      i = this.tokens.length;
      _results = [];
      while (i--) {
        if (res != null) return res;
        _results.push((function(i, store) {
          var tag, token, v, value, _ref3;
          _ref3 = token = _this.tokens[i], tag = _ref3[0], value = _ref3[1];
          v = fn(arguments);
          if ((v != null ? v.length : void 0) > 0 && (v != null ? v[0] : void 0) === 'return') {
            return (v.length > 1 ? v[1] : v.slice(1));
          }
        })(i, store));
      }
      return _results;
    };

    SmackLexer.prototype.is_reverse = function() {
      return this.last_operator === ' ';
    };

    SmackLexer.prototype.in_tag = false;

    SmackLexer.prototype._in_config = false;

    SmackLexer.prototype.in_config = function() {
      return this.in_tag && this._in_config;
    };

    SmackLexer.prototype.last = function(array, back) {
      return array[array.length - (back || 0) - 1];
    };

    SmackLexer.prototype.tag = function(index, tag) {
      var tok;
      return (tok = this.last(this.tokens, index)) && (tag ? tok[0] = tag : tok[0]);
    };

    SmackLexer.prototype.value = function(index, val) {
      var tok;
      return (tok = this.last(this.tokens, index)) && (val ? tok[1] = val : tok[1]);
    };

    SmackLexer.prototype.check_status = function() {
      return {
        "In tag?": this.in_tag,
        "In tag config": this.in_config(),
        "reverse?": this.is_reverse(),
        "tag()": this.tag(),
        "chunk": this.chunk
      };
    };

    SmackLexer.prototype.OpenTag = function() {
      var match, tag, _ref, _ref2, _ref3, _ref4;
      if ((_ref = this.TEST) != null ? _ref.OPENTAG : void 0) {
        console.log('Opentag w/ chunk:' + this.chunk);
      }
      if ((_ref2 = this.TEST) != null ? _ref2.OPENTAG : void 0) {
        console.log('Opentag RE:' + OpenTagRE);
      }
      if (!(match = OpenTagRE.exec(this.chunk))) return 0;
      if ((_ref3 = this.TEST) != null ? _ref3.OPENTAG : void 0) {
        console.log('Opentag matched');
      }
      _ref4 = match, match = _ref4[0], tag = _ref4[1];
      this.tokens.push(['OPENTAG', tag]);
      this.in_tag = true;
      this._in_config = true;
      return match.length;
    };

    SmackLexer.prototype.SmackOperator = function() {
      var match;
      if (!(this.tag() && this.tag() === 'OPENTAG' && (match = SmackOperatorRE.exec(this.chunk)))) {
        return 0;
      }
      this.tokens.push(['SMACK_OPERATOR', match[0]]);
      this.last_operator = match[0];
      this._in_config = match[0] !== ' ';
      return match[0].length;
    };

    SmackLexer.prototype.Midtag = function() {
      var match, tag, _ref;
      if (!(this.in_tag && (match = MidtagRE.exec(this.chunk)))) return 0;
      _ref = match, match = _ref[0], tag = _ref[1];
      this.tokens.push(['MIDTAG', tag]);
      this._in_config = !this.in_config();
      return match.length;
    };

    SmackLexer.prototype.CloseTag = function() {
      var match, op, tag, _ref;
      if (!(this.in_tag && (this.tag() === 'LITERAL' || this.in_config()) && (match = CloseTagRE.exec(this.chunk)))) {
        return 0;
      }
      _ref = match, match = _ref[0], op = _ref[1], tag = _ref[2];
      this.tokens.push(['SMACK_OPERATOR', op]);
      this.tokens.push(['CLOSETAG', tag]);
      this.in_tag = false;
      this._in_config = false;
      return match.length;
    };

    SmackLexer.prototype.Element = function() {
      var match, op, tag, _ref;
      if (!(this.in_config() && (match = Element.exec(this.chunk)))) return 0;
      _ref = match, match = _ref[0], tag = _ref[1], op = _ref[2];
      this.tokens.push(['ELEMENT', match]);
      return match.length;
    };

    SmackLexer.prototype.AttributeAbbreviation = function() {
      var key, match, value, _ref;
      if (!(this.in_config() && (match = AttrAbbr.exec(this.chunk)))) return 0;
      _ref = match, match = _ref[0], key = _ref[1], value = _ref[2];
      this.tokens.push([
        'ABBREVIATED_ATTRIBUTE', {
          key: key,
          value: value
        }
      ]);
      return match.length;
    };

    SmackLexer.prototype.AttributeList = function() {
      var attr, key, match, value, _i, _len, _ref, _ref2;
      if (!(this.in_config() && (match = AttrList.exec(this.chunk)))) return 0;
      this.tokens.push(['ATTR_LIST_OPEN', match[1]]);
      _ref = match[2].split(',');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        _ref2 = attr.split(/:\s/), key = _ref2[0], value = _ref2[1];
        this.tokens.push([
          'ATTRIBUTE', {
            key: key,
            value: value
          }
        ]);
      }
      this.tokens.push(['ATTR_LIST_CLOSE', match[3]]);
      return match[0].length;
    };

    SmackLexer.prototype.ZenOperator = function() {
      var match, op, tag, _ref, _ref2;
      if (!(match = ZenOperator.exec(this.chunk))) return 0;
      _ref = match, match = _ref[0], tag = _ref[1], op = _ref[2];
      if ((_ref2 = this.TEST) != null ? _ref2.ZENOP : void 0) console.log('zenop');
      this.tokens.push(['ZEN_OPERATOR', match]);
      return match.length;
    };

    SmackLexer.prototype.SmackVariable = function() {
      var match, op, tag, _ref, _ref2;
      if (!(match = SmackVariableRE.exec(this.chunk))) return 0;
      _ref = match, match = _ref[0], tag = _ref[1], op = _ref[2];
      if ((_ref2 = this.TEST) != null ? _ref2.SMACKVAR : void 0) {
        console.log('smackvar');
      }
      this.tokens.push(['SMACK_VARIABLE', match]);
      return match.length;
    };

    SmackLexer.prototype.SmackAlias = function() {
      var match, op, tag, _ref, _ref2;
      if (!(match = SmackAliasRE.exec(this.chunk))) return 0;
      _ref = match, match = _ref[0], tag = _ref[1], op = _ref[2];
      if ((_ref2 = this.TEST) != null ? _ref2.SMACKALIAS : void 0) {
        console.log('alias');
      }
      this.tokens.push(['SMACK_ALIAS', match]);
      return match.length;
    };

    SmackLexer.prototype.Literal = function() {
      var close_idx, literal, open_idx, this_close_idx, _ref, _ref2, _ref3, _ref4, _ref5, _ref6;
      if (this.in_config() || this.tag() === 'LITERAL') return 0;
      open_idx = (_ref = (_ref2 = OpenTagTest.exec(this.chunk)) != null ? _ref2.index : void 0) != null ? _ref : this.chunk.length;
      this_close_idx = !this.is_reverse() && this.tag() === 'MIDTAG' ? close_idx = (_ref3 = (_ref4 = CloseTagTest.exec(this.chunk)) != null ? _ref4.index : void 0) != null ? _ref3 : this.chunk.length : this.is_reverse && this.tag() === 'SMACK_OPERATOR' && this.value() === ' ' ? close_idx = (_ref5 = (_ref6 = MidtagTest.exec(this.chunk)) != null ? _ref6.index : void 0) != null ? _ref5 : this.chunk.length : void 0;
      if (!this_close_idx) return 0;
      literal = this.chunk.slice(0, this_close_idx);
      this.tokens.push(['LITERAL', literal]);
      return literal.length;
    };

    SmackLexer.prototype.Whitespace = function() {
      var match;
      if (!(match = Whitespace.exec(this.chunk))) return 0;
      return match[0].length;
    };

    SmackLexer.prototype.LexerError = function() {
      var tok;
      try {
        throw null;
      } catch (e) {
        console.log('--- ERRROR ---');
        console.log("Not a token: " + this.chunk);
        console.log('@tokens');
        console.log(this.tokens);
        throw "Fix your lexers";
      }
      tok = this.chunk[0];
      this.tokens.push(['TOKEN', tok]);
      return tok.length;
    };

    return SmackLexer;

  })();

  Element = /^[a-zA-Z][a-zA-Z0-9]*/;

  AttrAbbr = /^([#.]+)([a-zA-Z][a-zA-Z0-9\-_]*)/;

  AttrKey = /^[a-zA-Z][a-zA-Z0-9\-_]*/;

  AttrVal = /^[a-zA-Z_ ][\-a-zA-Z0-9_ .]*/;

  AttrList = /^(\|)([\s\S]*?)(\|)/;

  Whitespace = /^\s+/;

  SmackOperatorRE = /^([\S]*?>|\x20)/;

  SmackOperatorTest = /([\S]*?>|\x20)/;

  SmackAliasRE = /^@[a-zA-Z0-9_\-$]+/;

  SmackVariableRE = /^$([a-zA-Z0-9_$]+)|${?([a-zA-Z0-9_$\[\].]+)}/;

  ZenOperator = /^[>+]/;

  OpenTagRE = /^(~[|])/;

  OpenTagTest = /(~[|])/;

  CloseTagRE = /^(~>[\S]*?|\x20)([|]~)/;

  CloseTagTest = /(~>[\S]*?|\x20)([|]~)/;

  MidtagRE = /^(~[\s]|[\s]~(?!>))/;

  MidtagTest = /(~[\s]|[\s]~(?!>))/;

  Literal = /^[\s\S]+/;

  window.SmackLexer = SmackLexer;

  if ((typeof module !== "undefined" && module !== null) && !(module.parent != null)) {
    _ = require('underscore');
    t = this;
    _ref = require('assert');
    for (k in _ref) {
      v = _ref[k];
      this[k] = v;
    }
    ok = this['ok'];
    lex = new SmackLexer;
    console.log(lex.tokenize('~|> p#status.block-message |alt: Bla Bla Bla| > div.clear-fix~ Upload Successful! |~'));
    console.log(lex.tokenize('~|> p~ |~'));
  }

}).call(this);
(function() {
  var Parser, SmackLexer, alt, alternatives, grammar, k, lexer, name, o, ok, operators, parser, t, token, tokens, unwrap, v, _, _ref;

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
        return new Body([$1]);
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
    /*
    
      *** Smack Grammar ***
    
      Root -> Body
    
      Body ->
          Smack_Tag
        | Smack_Tag Body
    
      Smack_Tag ->
          OPENTAG Smack_Tag_Config Literal CLOSETAG
        | OPENTAG Literal Smack_Tag_Config CLOSETAG
    
      Smack_Tag_Config ->
          HtmlTag
        | HtmlTag ZEN_OPERATOR HtmlTag
    
      HtmlTag ->
          ELEMENT HTML_ID HTML_CLASSES HTML_ATTRIBUTES
    */
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
        try {
          alt[0].split(' ');
        } catch (e) {
          console.log("alt[0] invalid in: " + alt);
        }
        try {
          _ref = alt[0].split(' ');
          for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
            token = _ref[_j];
            if (!grammar[token]) tokens.push(token);
          }
        } catch (e) {
          console.log("alt[0] invalid in: " + alt);
          console.log(e);
        }
        if (name === 'Root') alt[1] = "return " + alt[1];
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

  if ((typeof module !== "undefined" && module !== null) && !(module.parent != null)) {
    _ = require('underscore');
    SmackLexer = require('./SmackLexer.coffee').SmackLexer;
    parser = exports.parser;
    parser.yy = require('./SmackNodes');
    t = this;
    _ref = require('assert');
    for (k in _ref) {
      v = _ref[k];
      this[k] = v;
    }
    ok = this['ok'];
    lexer = new SmackLexer;
    parser.lexer = {
      lex: function() {
        var tag, _ref2;
        _ref2 = this.tokens[this.pos++] || [''], tag = _ref2[0], this.yytext = _ref2[1];
        return tag;
      },
      setInput: function(tokens) {
        this.tokens = tokens;
        return this.pos = 0;
      },
      upcomingInput: function() {
        return "";
      }
    };
    tokens = lexer.tokenize('~|> p#dialog.clearfix.poopbutt |target: http://www.fart.com| > span.error ~ Upload Successful! |~');
    tokens = lexer.tokenize('~|> p~ |~');
    console.log(parser.parse(tokens).compile());
  }

}).call(this);
(function() {
  var ALIAS_LOOKUP, ATTR_ABBR_LOOKUP, Body, HtmlTag, Literal, Node, SINGLETONS, SmackBlock, SmackLexer, ZenTag, k, lexer, ok, parser, t, v, _, _h, _ref;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; }, __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (__hasProp.call(this, i) && this[i] === item) return i; } return -1; };

  if (typeof module !== "undefined" && module !== null) {
    _h = require('./Helper')._h;
  }

  SINGLETONS = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'param', 'source'];

  ATTR_ABBR_LOOKUP = {
    '#': 'id',
    '.': 'class'
  };

  ALIAS_LOOKUP = {
    iframe: 'iframe style="width:0;height:0;" src=""'
  };

  exports.Node = Node = (function() {

    function Node(nodes) {
      this.nodes = nodes != null ? nodes : [];
    }

    Node.prototype.push = function(node) {
      return this.nodes.push(node);
    };

    return Node;

  })();

  exports.Body = Body = (function() {

    __extends(Body, Node);

    function Body() {
      Body.__super__.constructor.apply(this, arguments);
    }

    Body.prototype.compile = function() {
      var n;
      return ((function() {
        var _i, _len, _ref, _results;
        _ref = this.nodes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          n = _ref[_i];
          _results.push(n.compile());
        }
        return _results;
      }).call(this)).join('');
    };

    return Body;

  })();

  exports.SmackBlock = SmackBlock = (function() {

    __extends(SmackBlock, Node);

    function SmackBlock(front_op, zentag, literal, rear_op) {
      this.front_op = front_op;
      this.zentag = zentag;
      this.literal = literal;
      this.rear_op = rear_op;
    }

    SmackBlock.prototype.compile = function() {
      var foot, head, indent, _ref;
      _ref = this.zentag.compile(), head = _ref[0], foot = _ref[1], indent = _ref[2];
      return "" + head + indent + this.literal + (indent !== '' ? '\n' : void 0) + foot;
    };

    return SmackBlock;

  })();

  exports.ZenTag = ZenTag = (function() {

    __extends(ZenTag, Node);

    function ZenTag(tag) {
      this.tags = [
        {
          op: '>',
          tag: tag
        }
      ];
    }

    ZenTag.prototype.add = function(op, tag) {
      return this.tags.push({
        op: tag
      });
    };

    ZenTag.prototype.compile = function() {
      var close_tags, content_lvl, foot, head, lvl, op, should_indent, t, tag, tag_c_stack, tag_stack, _i, _len, _ref, _ref2;
      tag_stack = [];
      tag_c_stack = [];
      lvl = 0;
      should_indent = lvl !== -1;
      _ref = this.tags;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref2 = _ref[_i], op = _ref2.op, tag = _ref2.tag;
        tag_c_stack.push(should_indent ? _h.indent(lvl) + tag.compile() + '\n' : tag.compile());
        switch (op) {
          case '>':
            tag_stack.push(tag.el);
            lvl++;
            break;
          case '+':
            tag_stack.splice(-1, 0, tag.el);
        }
      }
      content_lvl = lvl + 1;
      head = tag_c_stack.join('');
      close_tags = (function() {
        var _results;
        _results = [];
        while (t = tag_stack.pop()) {
          if (!(__indexOf.call(SINGLETONS, t) < 0)) continue;
          if (!should_indent) '</' + t + '>';
          _results.push(_h.indent(--lvl) + ("</" + t + ">\n"));
        }
        return _results;
      })();
      foot = close_tags.join('');
      return [head, foot, should_indent ? _h.indent(content_lvl) : ''];
    };

    return ZenTag;

  })();

  exports.HtmlTag = HtmlTag = (function() {

    __extends(HtmlTag, Node);

    function HtmlTag(el, abbreviated, attributes) {
      this.el = el;
      this.abbreviated = abbreviated;
      this.attributes = attributes;
    }

    HtmlTag.prototype.compile = function() {
      var attr_s, attrs, id_class_s, k, key, v, value, _i, _j, _len, _len2, _ref, _ref2, _ref3, _ref4;
      attrs = {};
      _ref = this.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref2 = _ref[_i], key = _ref2.key, value = _ref2.value;
        attrs[key] = value;
      }
      _ref3 = this.abbreviated;
      for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
        _ref4 = _ref3[_j], key = _ref4.key, value = _ref4.value;
        key = ATTR_ABBR_LOOKUP[key];
        if ((attrs[key] != null) && key === 'class') {
          attrs[key] += ' ' + value;
        } else {
          attrs[key] = value;
        }
      }
      id_class_s = _h.join((function() {
        var _results;
        _results = [];
        for (k in attrs) {
          v = attrs[k];
          if (k === 'id' || k === 'class') _results.push(' ' + k + '="' + v + '"');
        }
        return _results;
      })());
      attr_s = _h.join((function() {
        var _results;
        _results = [];
        for (k in attrs) {
          v = attrs[k];
          if (k !== 'id' && k !== 'class') _results.push(' ' + k + '="' + v + '"');
        }
        return _results;
      })());
      if (attrs == null) "<" + this.el + ">";
      return "<" + this.el + id_class_s + attr_s + ">";
    };

    return HtmlTag;

  })();

  exports.Literal = Literal = (function() {

    __extends(Literal, Node);

    function Literal(value) {
      this.value = value;
    }

    Literal.prototype.compile = function() {
      return "" + this.value;
    };

    return Literal;

  })();

  if ((typeof module !== "undefined" && module !== null) && !(module.parent != null)) {
    _ = require('underscore');
    _.mixin(require('underscore.inspector'));
    SmackLexer = require('./SmackLexer.coffee').SmackLexer;
    parser = require('./SmackParser.coffee').parser;
    parser.yy = require('./SmackNodes');
    t = this;
    _ref = require('assert');
    for (k in _ref) {
      v = _ref[k];
      this[k] = v;
    }
    ok = this['ok'];
    lexer = new SmackLexer;
    parser.lexer = {
      lex: function() {
        var tag, _ref2;
        _ref2 = this.tokens[this.pos++] || [''], tag = _ref2[0], this.yytext = _ref2[1];
        return tag;
      },
      setInput: function(tokens) {
        this.tokens = tokens;
        return this.pos = 0;
      },
      upcomingInput: function() {
        return "";
      }
    };
  }

}).call(this);
