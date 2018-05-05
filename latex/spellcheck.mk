# Simple spellcheck module

SPELL      ?= aspell
SPELLFLAGS ?= --lang=en --mode=tex --personal=${PWD}/spellcheck-dict --dont-backup

spellcheck:
	find . -name "*.tex" -exec ${SPELL} ${SPELLFLAGS} check "{}" \;

.PHONY: spellcheck

# vim: ft=make
