.PHONY: test

test:
	busted

test-file:
	busted $(FILE)
