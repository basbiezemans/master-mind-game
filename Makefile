install-elm:
	curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
	gunzip elm.gz
	chmod +x elm
	sudo mv elm /usr/local/bin/
	elm --help

install-elm-test:
	npm install --save-dev elm-test

test:
	npx elm-test

build:
	elm make src/Main.elm --output app.js

all: test build