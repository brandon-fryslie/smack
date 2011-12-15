
all: smack parsers lectura

.PHONY: clean
clean:
	rm -f ./lib/smack/*
	rm -f SmackCompiler.js
	rm -f ./src/ZenParser.js ./src/Parser.js
	rm -f scripts.js

smack:
	coffee ./src/NodeLoad.coffee > SmackCompiler.js

parsers: ./src/Grammar.coffee ./src/ZenGrammar.coffee
	cake build:parsers

lectura: scripts.coffee
	coffee -c scripts.coffee

shared:
	coffee ./src/NodeLoad.coffee > /Library/WebServer/Documents/shared/js/SmackCompiler.js

upload: scripts.coffee ../../index.php
	coffee -c scripts.coffee
	coffee ./src/NodeLoad.coffee > SmackCompiler.js
	
	scp SmackCompiler.js bmf@lectura.cs.arizona.edu:/home/bmf/public_html/shared/js/
	scp ../../index.php bmf@lectura.cs.arizona.edu:/home/bmf/public_html/smack/
	scp scripts.js bmf@lectura.cs.arizona.edu:/home/bmf/public_html/smack/resources/js/
	rm -f scripts.js SmackCompiler.js
