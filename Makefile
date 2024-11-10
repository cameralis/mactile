override CXXFLAGS += -O2 -Wall -fobjc-arc

all: mactile

clean:
	rm -f mactile

mactile: src/mactile.c src/mouse.c src/window.m
	clang $(CXXFLAGS) -o $@ $^ -framework AppKit