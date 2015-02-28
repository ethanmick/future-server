#
# Ethan Mick
# 2015
#

run:
	node coffee_bridge.js


unit:
	./node_modules/mocha/bin/_mocha --compilers coffee:coffee-script/register ./test/unit

cov:
	./node_modules/mocha/bin/_mocha --compilers coffee:coffee-script/register --require ./node_modules/blanket-node/bin/index.js -R travis-cov ./test/unit

report:
	./node_modules/mocha/bin/_mocha --compilers coffee:coffee-script/register --require ./node_modules/blanket-node/bin/index.js -R html-cov > coverage.html ./test/unit
	open coverage.html

lint:
	./node_modules/coffeelint/bin/coffeelint ./lib ./server.coffee

check-dependencies:
	./node_modules/david/bin/david.js
