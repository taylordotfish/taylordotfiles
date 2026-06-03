CC ?= gcc
CFLAGS := -std=c11 -O2 -Wall -Wextra -pedantic $(CFLAGS)
LDLIBS = -lX11 -lXinerama -lXrandr

SOURCES = main.c focused.c
HEADERS = debug.h focused.h intersect.h

xmonutil: $(SOURCES) $(HEADERS)
	$(CC) $(CFLAGS) -o $@ $(SOURCES) $(LDLIBS)
