TESTS  = $(shell find spec/dashboard -type f -iname "*.coffee")
REPORTER = spec

build:
	@echo "make [test|release]"

test:
	@NODE_ENV=test ./node_modules/.bin/mocha  --compilers coffee:coffee-script \
		--reporter $(REPORTER) \
		--timeout 0 \
		--slow 50000 \
		--ui bdd \
		$(TESTS)
release:
	@git checkout release
	@git pull origin master
	@git merge master
	@git push origin release
	@git checkout master

.PHONY: release test
