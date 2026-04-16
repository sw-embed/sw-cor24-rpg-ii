# Makefile -- sw-cor24-rpg-ii
# Minimal Makefile following sw-cor24-forth convention.

.PHONY: all test demo clean

all:
	./build.sh build

test:
	./build.sh test

demo:
	./demo.sh

clean:
	./build.sh clean
