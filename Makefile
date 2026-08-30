PREFIX ?= /usr/local
DESTDIR ?=
INSTALL ?= install
SCRIPT_NAME := git-proxy-cache-shell
SCRIPT_SRC := src/$(SCRIPT_NAME)
SCRIPT_DEST := $(DESTDIR)$(PREFIX)/bin/$(SCRIPT_NAME)
SHELL_FILES := src/git-proxy-cache-shell tests/*.sh

.PHONY: all install test lint fmt-check

all:
	@printf 'Targets: install, test, lint, fmt-check\n'

install:
	$(INSTALL) -d -m 755 "$(DESTDIR)$(PREFIX)/bin"
	$(INSTALL) -m 755 "$(SCRIPT_SRC)" "$(SCRIPT_DEST)"

test:
	for test_file in ./tests/test_*.sh; do \
		if [ -f "$$test_file" ]; then \
			bash "$$test_file"; \
		fi; \
	done

lint:
	shellcheck -x -e SC2317 $(SHELL_FILES)

fmt-check:
	shfmt -d $(SHELL_FILES)