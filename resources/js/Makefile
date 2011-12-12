
all: smack parser browser lectura

.PHONY: clean
clean:
	rm -f ./lib/smack/*
	rm -f SmackCompiler.js

smack:
	coffee -c -o ./lib/smack ./src/Helper.coffee
	cake build:smack

parser:
	rm -f ./lib/smack/Parser.js
	cake build:parser

browser:
	rm -f SmackCompiler.js
	cake build:browser

lectura: scripts.coffee
	coffee -c scripts.coffee

shared: SmackCompiler.js
	cp SmackCompiler.js ../../../shared/js/

upload: SmackCompiler.js scripts.js ../../index.php
	scp SmackCompiler.js ../../index.php scripts.js bmf@lectura.cs.arizona.edu:/home/bmf/public_html/shared/js/
