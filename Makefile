#
# Ethan Mick
# 2015
#

run:
	node coffee_bridge.js


unit:
	./node_modules/mocha/bin/_mocha --compilers coffee:coffee-script/register ./test/unit
