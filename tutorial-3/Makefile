.PHONY: all clean install

all: hello

clean:
	rm -f hello

hello: hello.c
	gcc -Wall -g hello.c -o hello

install:
	mkdir -p $(DESTDIR)/usr/bin
	cp hello $(DESTDIR)/usr/bin/hello
