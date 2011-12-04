(function() {
  var AttrAbbr, AttrKey, AttrList, AttrVal, CloseTagRE, CloseTagTest, Element, Lexer, MidtagRE, MidtagTest, OpenTagRE, OpenTagTest, SmackAliasRE, SmackOperatorRE, SmackOperatorTest, SmackVariableRE, Whitespace, ZenOperator;

  Lexer = (function() {

    function Lexer() {}

    Lexer.prototype.TEST = {
      MAIN: 0,
      OPENTAG: 0,
      WHITESPACE: 0,
      FOR_TOKENS: 0,
      ELEMENT: 0,
      LITERAL: 0
    };

    Lexer.prototype.tokenize = function(code) {
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

    Lexer.prototype.closeTags = function() {
      return '</div>';
    };

    Lexer.prototype.for_tokens = function(fn) {
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

    Lexer.prototype.is_reverse = function() {
      return this.last_operator === ' ';
    };

    Lexer.prototype.in_tag = false;

    Lexer.prototype._in_config = false;

    Lexer.prototype.in_config = function() {
      return this.in_tag && this._in_config;
    };

    Lexer.prototype.last = function(array, back) {
      return array[array.length - (back || 0) - 1];
    };

    Lexer.prototype.tag = function(index, tag) {
      var tok;
      return (tok = this.last(this.tokens, index)) && (tag ? tok[0] = tag : tok[0]);
    };

    Lexer.prototype.value = function(index, val) {
      var tok;
      return (tok = this.last(this.tokens, index)) && (val ? tok[1] = val : tok[1]);
    };

    Lexer.prototype.check_status = function() {
      return {
        "In tag?": this.in_tag,
        "In tag config": this.in_config(),
        "reverse?": this.is_reverse(),
        "tag()": this.tag(),
        "chunk": this.chunk
      };
    };

    Lexer.prototype.OpenTag = function() {
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

    Lexer.prototype.SmackOperator = function() {
      var match;
      if (!(this.tag() && this.tag() === 'OPENTAG' && (match = SmackOperatorRE.exec(this.chunk)))) {
        return 0;
      }
      this.tokens.push(['SMACK_OPERATOR', match[0]]);
      this.last_operator = match[0];
      this._in_config = match[0] !== ' ';
      return match[0].length;
    };

    Lexer.prototype.Midtag = function() {
      var match, tag, _ref;
      if (!(this.in_tag && (match = MidtagRE.exec(this.chunk)))) return 0;
      _ref = match, match = _ref[0], tag = _ref[1];
      this.tokens.push(['MIDTAG', tag]);
      this._in_config = !this.in_config();
      return match.length;
    };

    Lexer.prototype.CloseTag = function() {
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

    Lexer.prototype.Element = function() {
      var match, op, tag, _ref;
      if (!(this.in_config() && (match = Element.exec(this.chunk)))) return 0;
      _ref = match, match = _ref[0], tag = _ref[1], op = _ref[2];
      this.tokens.push(['ELEMENT', match]);
      return match.length;
    };

    Lexer.prototype.AttributeAbbreviation = function() {
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

    Lexer.prototype.AttributeList = function() {
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

    Lexer.prototype.ZenOperator = function() {
      var match, op, tag, _ref, _ref2;
      if (!(match = ZenOperator.exec(this.chunk))) return 0;
      _ref = match, match = _ref[0], tag = _ref[1], op = _ref[2];
      if ((_ref2 = this.TEST) != null ? _ref2.ZENOP : void 0) console.log('zenop');
      this.tokens.push(['ZEN_OPERATOR', match]);
      return match.length;
    };

    Lexer.prototype.SmackVariable = function() {
      var match, op, tag, _ref, _ref2;
      if (!(match = SmackVariableRE.exec(this.chunk))) return 0;
      _ref = match, match = _ref[0], tag = _ref[1], op = _ref[2];
      if ((_ref2 = this.TEST) != null ? _ref2.SMACKVAR : void 0) {
        console.log('smackvar');
      }
      this.tokens.push(['SMACK_VARIABLE', match]);
      return match.length;
    };

    Lexer.prototype.SmackAlias = function() {
      var match, op, tag, _ref, _ref2;
      if (!(match = SmackAliasRE.exec(this.chunk))) return 0;
      _ref = match, match = _ref[0], tag = _ref[1], op = _ref[2];
      if ((_ref2 = this.TEST) != null ? _ref2.SMACKALIAS : void 0) {
        console.log('alias');
      }
      this.tokens.push(['SMACK_ALIAS', match]);
      return match.length;
    };

    Lexer.prototype.Literal = function() {
      var close_idx, literal, open_idx, this_close_idx, _ref, _ref2, _ref3, _ref4, _ref5, _ref6;
      if (this.in_config() || this.tag() === 'LITERAL') return 0;
      open_idx = (_ref = (_ref2 = OpenTagTest.exec(this.chunk)) != null ? _ref2.index : void 0) != null ? _ref : this.chunk.length;
      this_close_idx = !this.is_reverse() && this.tag() === 'MIDTAG' ? close_idx = (_ref3 = (_ref4 = CloseTagTest.exec(this.chunk)) != null ? _ref4.index : void 0) != null ? _ref3 : this.chunk.length : this.is_reverse && this.tag() === 'SMACK_OPERATOR' && this.value() === ' ' ? close_idx = (_ref5 = (_ref6 = MidtagTest.exec(this.chunk)) != null ? _ref6.index : void 0) != null ? _ref5 : this.chunk.length : void 0;
      if (!this_close_idx) return 0;
      literal = this.chunk.slice(0, this_close_idx);
      this.tokens.push(['LITERAL', literal]);
      return literal.length;
    };

    Lexer.prototype.Whitespace = function() {
      var match;
      if (!(match = Whitespace.exec(this.chunk))) return 0;
      return match[0].length;
    };

    Lexer.prototype.LexerError = function() {
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

    return Lexer;

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

  exports.Lexer = Lexer;

}).call(this);
