CC ?= gcc
CFLAGS := -std=c11 -O2 -Wall -Wextra -pedantic $(CFLAGS)
LDLIBS = -lpulse

pulse-max-volume: main.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)
