# Tutorial 4: making full use of debhelper

In tutorial 3 you have learned how to package an application that requires compilation. You have also learned what debhelper is and how it fits in the packaging process. But there are issues with the packaging work in tutorial 3.

You have to specify in the `rules` file how your application is to be compiled. But many applications use a small number of distinct build systems. For example, almost all C and C++ applications/libraries nowadays use GNU Autoconf/Automake, or CMake, or plain 'make' with a few standard target names. Almost all Python applications use setuptools. Almost all Ruby applications/libraries use RubyGems. Almost all Node.js applications/libraries use NPM or Yarn. The list goes on. There are very few custom, non-standard build systems out there. Can debhelper figure out automatically what build system we're using and take care of the compile and install-into-package-root steps for us? Why yes, it can!

Also, imagine that you have to conform to even more Debian packaging requirements. You will have to find out which `dh_` tool to call and when in order to conform to those requirements. Can debhelper automatically figure out all possible things it can do instead of making you choose? Yes it can!

In this tutorial we will show you how to use debhelper to its fullest. Your rules file will delegate all work to debhelper, and will become very small as a result.

We will reuse the application from tutorial 3, and only modify the packaging work. So as a side thing we will also demonstrate when is a good time to update the Debian package revision number but not the application number.

**Table of contents**

 * Preparation
   - Reproducing hello 3.0.0
   - Reproducing `debian/control`
   - Reproducing `debian/compat`
   - Updating `debian/changelog`
 * Delegating work to debhelper
   - Updating `debian/rules`
   - Building and verifying the package
   - Analysis
 * Delegating everything to debhelper
   - Updating `debian/rules`
 * Conclusion

## Preparation

Let's prepare by copying over some things from tutorial 3, unchanged.

### Reproducing hello 3.0.0

~~~bash
mkdir tutorial-4
cd tutorial-4
editor hello.c
editor Makefile
~~~

hello.c must contain:

~~~c
#include <stdio.h>

int
main() {
	printf("hello 3\n");
	return 0;
}
~~~

Makefile must contain:

~~~Makefile
.PHONY: all clean install

all: hello

clean:
	rm -f hello

hello: hello.c
	gcc -Wall -g hello.c -o hello

install:
	mkdir -p $(DESTDIR)/usr/bin
	cp hello $(DESTDIR)/usr/bin/hello
~~~

### Reproducing `debian/control`

The control file remains the same compared to tutorial 3:

~~~
Source: hello
Section: devel
Priority: optional
Maintainer: John Doe <john@doe.com>
Build-Depends: build-essential, debhelper (>= 9)

Package: hello
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: John's hello package
 John's package is written in C
 and prints a greeting.
 .
 It is awesome.
~~~

### Reproducing `debian/compat`

The compatibility level remains the same compared to tutorial 3:

~~~bash
echo 9 > debian/compat
~~~

### Updating `debian/changelog`

We add a new changelog entry to the beginning of the file. The full file looks like this:

~~~
hello (3.0.0-2) stretch; urgency=medium

  * Made full use of debhelper.

 -- John Doe <john@doe.com>  Thu, 06 Jul 2017 13:59:26 +0000

hello (3.0.0-1) stretch; urgency=medium

  * Rewrote application in C.

 -- John Doe <john@doe.com>  Thu, 06 Jul 2017 13:59:26 +0000

hello (2.0.0-1) stretch; urgency=medium

  * Initial packaging work with dpkg-buildpackage.

 -- John Doe <john@doe.com>  Thu, 06 Jul 2017 09:19:24 +0000
~~~

Note that we haven't changed the application version number -- it stays at 3.0.0. But we bumped the Debian package revision number from 1 to 2 because we are going to update the packaging work only.

## Delegating work to debhelper

Now that we're done preparing, let's modify the package to use debhelper.

### Updating `debian/rules`

For each target we simply call "dh <target name>":

~~~Makefile
#!/usr/bin/make -f

clean:
	dh clean

build:
	dh build

binary:
	dh binary
~~~

### Building and verifying the package

~~~
$ dpkg-buildpackage -b
$ sudo apt install -y ../hello_3.0.0-2_<ARCH>.deb
$ hello
hello 3.0.0
~~~

### Analysis

What? Is that all? Yes it is.

 * `dh clean` automatically figures out that it needs to call `make clean`.
 * `dh build` automatically figures out that it needs to call `make`.
 * `dh binary` automatically figures out that it needs to call `make install DESTDIR=debian/hello`, `dh_strip`, `dh_gencontrol` and `dh_builddeb`.

But if you look at the output then you see that debhelper actually does a whole lot more. You see that `dh binary` calls `dh_auto_install`, and that *that* tool is what is responsible for calling `make install`. You also see that `dh binary` calls `dh_compress`, `dh_makeshlibs`, etc.

If you are interested in learning what these underlying commands do, then you can consult [the debhelper man page](https://manpages.debian.org/stretch/debhelper/debhelper.7.en.html). But the man page is quite large and frankly the way it is written comes over as a bit arcane. Luckily there is an easier way to figure out what actually happened: by inspecting the package contents using Midnight Commander, as you learned in tutorial 1.

If you compare `hello_3.0.0-1_<ARCH>.deb` with `hello_3.0.0-2_<ARCH>.deb`, then you will see the following differences:

 * A new file DEBIAN/md5sums have been added. This file is actually pretty important because it allows dpkg to verify whether managed files have been corrupted.
 * A new file CONTENTS/usr/share/doc/hello/changelog.Debian.gz has been added. This is conform the Debian Policy requirements.

## Delegating everything to debhelper

We can make the rules file even smaller:

~~~Makefile
#!/usr/bin/make -f

%:
	dh $@
~~~

Woah, what sort of black magic is this?

The "%" is [the wildcard pattern rule](https://www.gnu.org/software/make/manual/html_node/Pattern-Rules.html), similar to "*" in the context of bash. So "%:" is [the match-anything target](https://www.gnu.org/software/make/manual/html_node/Match_002dAnything-Rules.html#Match_002dAnything-Rules). "$@" refers to the actual target name as passed to Make. So the above rules file simply forwards all make commands to debhelper. It is semantically equivalent to the rules file you saw in subsection "Delegating work to debhelper".

## Conclusion

Congratulations, you're now making full use of debhelper. And on the side you have also learned when is an appropriate time to bump the Debian package revision number but not the application version number.

But what do you do when debhelper doesn't do the right thing, for example when your application is using a custom build system that debhelper does not recognize? Do you fall back to not using debhelper as much, like you did in tutorial 3? There is a better way, which you will learn in the next tutorial.
