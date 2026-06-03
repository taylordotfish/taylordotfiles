# Copyright (C) 2026 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later
cache := $(HOME)/.cache/monitor-utils
config := $(HOME)/.config/monitor-utils

$(cache)/globals.json: $(cache)/monitors.json \
		$(wildcard $(config)/settings.json)
	./globals.sh > $@.tmp
	mv -T -- $@.tmp $@

$(cache)/monitors.json: $(cache)/outputs.json \
		$(wildcard $(config)/monitors.json $(config)/outputs.json)
	./monitors.sh > $@.tmp
	mv -T -- $@.tmp $@

$(cache)/outputs.json: $(cache)/screens.json
	../xmonutil.sh outputs > $@

$(cache)/screens.json: screens-outdated
	set -euf; \
	if [ -e $@ ]; then \
		screens=$$(../xmonutil.sh screens); \
		if [ "$$screens" != "$$(cat -- $@)" ]; then \
			printf '%s\n' "$$screens" > $@; \
		fi; \
	else \
		../xmonutil.sh screens > $@; \
	fi; \
	touch $(cache)/screens.stamp

.PHONY: screens-outdated
screens-outdated:
