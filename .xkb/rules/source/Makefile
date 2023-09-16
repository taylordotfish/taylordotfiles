BUILD_DIR = ..
TARGET = local
SOURCE := $(TARGET).add
SYSTEM_SRC = /usr/share/X11/xkb/rules/evdev

add_build = $(addprefix $(BUILD_DIR)/,$(1))
TARGET := $(call add_build,$(TARGET))
TARGETS = $(TARGET) $(TARGET).lst

.PHONY: all
all: $(TARGETS)

$(TARGET): $(SYSTEM_SRC) $(SOURCE)
$(TARGET).lst: $(SYSTEM_SRC).lst $(SOURCE).lst

$(TARGETS): | $(BUILD_DIR)
	(for f in $^; do cat "$$f"; echo; echo; done) | head -n-2 > $@

$(BUILD_DIR):
	mkdir -p $@

.PHONY: clean
clean:
	rm -f $(TARGETS)
