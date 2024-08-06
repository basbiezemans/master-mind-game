install-elm:
	curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
	gunzip elm.gz
	chmod +x elm
	sudo mv elm /usr/local/bin/
	elm --help

install-npm-packages:
	npm install elm-test --save-dev
	npm install uglify-js -g
	npm install elm-format -g

format:
	elm-format src/ --yes

test:
	npx elm-test

build:
	elm make src/Main.elm --output app.js

build-debug:
	elm make src/Main.elm --output app.js --debug

optimize:
	elm make src/Main.elm --optimize --output=app.js
	@echo "Optimizing app.js ..."
	@uglifyjs app.js --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle --output app.min.js
	@echo
	@echo "Initial size: $$(cat app.js | wc -c) bytes (app.js)"
	@echo "Minfied size: $$(cat app.min.js | wc -c) bytes (app.min.js)"
	@echo "Gzipped size: $$(cat app.min.js | gzip -c | wc -c) bytes"

all: format test build