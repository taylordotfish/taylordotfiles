NAME = local
UPSTREAM = /usr/share/X11/xkb/rules/evdev
BUILD_DIR = ..

SOURCES = $(NAME) $(NAME).lst
OUTPUTS = $(addprefix $(BUILD_DIR)/,$(SOURCES))

.PHONY: all
all: $(OUTPUTS)

$(OUTPUTS): | $(BUILD_DIR)
	for f in $^; do echo; cat "$$f"; done | tail -n+2 > $@

define make_rule
$(BUILD_DIR)/$1: $$(UPSTREAM)$$(suffix $1) $1
endef

$(foreach source,$(SOURCES),$(eval $(call make_rule,$(source))))

$(BUILD_DIR):
	mkdir -p $@

.PHONY: clean
clean:
	rm -f $(OUTPUTS)
