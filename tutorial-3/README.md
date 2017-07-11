# Tutorial 3: packaging a compiled application, introducing debhelper

So far we have only worked with packaging platform-independent Python applications. In this tutorial you will learn how to package an application that needs to be compiled. We will also introduce you to `debhelper`, which you have been using so far without understanding it.

The application in question is a hello world C program that prints "hello 3".

**Table of contents**

 * What is debhelper?
 * Preparation
 * Creating the `debian/` subdirectory
   - `debian/control`
   - `debian/changelog`
   - `debian/compat`
   - `debian/rules`
 * Debugging symbol packages
 * Building the package
   - What is debhelper doing under the hood?
 * Verifying that it works
 * Conclusion

---

## What is debhelper?

[Debhelper](https://manpages.debian.org/stretch/debhelper/debhelper.7.en.html) is a tool that automates various common aspects of package building. It consists of a collection of commands. In tutorial 2, you've been using debhelper through the `dh_gencontrol` and `dh_builddeb` commands. In this tutorial we will introduce you to more debhelper commands.

Most Debian packages delegate almost all work to debhelper where possible, but that doesn't help you understand what's going on. So in this tutorial we will show you how to use debhelper in an as minimal manner as possible; in the next tutorials we will show you how to use debhelper to the fullest.

## Preparation

Create a directory for this tutorial and populate it with application source code and a Makefile:

~~~bash
mkdir tutorial-3
cd tutorial-3
editor hello.c
editor Makefile
~~~

hello.c must contain:

~~~c
#include <stdio.h>

int
main() {
	printf("hello 3.0.0\n");
	return 0;
}
~~~

The Makefile contains three main targets: `make` compiles hello.c, `make clean` removes compilation products and `make install` installs the application to a bin directory.

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

Compile the application with make and verify that it works:

~~~
$ make
$ ./hello
hello 3.0.0
~~~

## Creating the `debian/` subdirectory

### `debian/control`

The control file must contain:

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

Compared to tutorial 2 we have made the following changes:

 * Added a "Build-Dependency" field. This field specifies which packages must be installed in order to be able to build this Debian package. This is a distinct concept from *package* dependencies, which is what the resulting package says it will depend on. Anything you specify as a Build-Dependency is not automatically registered as a package dependency, and vice versa.

   In our case, we specify build-essential because we need a C compiler, and debhelper at least version 9.

   `dpkg-buildpackage` checks whether all Build-Dependencies are installed, and refuses to continue if any is missing. There are even [tools out there which will automatically install all Build-Dependencies](http://manpages.ubuntu.com/manpages/xenial/man1/mk-build-deps.1.html); you will learn these tools in later tutorials.

 * Changed the "Architecture" field from "all" (package works on all architectures, does not require compilation) to "any" (package can be compiled for any Debian/Ubuntu-supported architecture).

 * Removed the Python dependency.

 * Added two dependencies: `${shlibs:Depends}, ${misc:Depends}`. These are magic keywords that are substituted by `dh_makeshlibs` and `dh_gencontrol`.

   `dh_makeshlibs` scans all the binary files in our package root directory, automatically infers any shared library dependencies that they have, and assigns them to these variables. When `dh_gencontrol` generates a control file, it substitutes these variables using the information inferred by `dh_makeshlibs`.

   Our example program is a C program, so it depends on glibc. Indeed, `dh_gencontrol` substitutes these keywords with "glibc".

 * Updated the description.

### `debian/changelog`

We add a new changelog entry to the beginning of the file. The full file looks like this:

~~~
hello (3.0.0-1) stretch; urgency=medium

  * Rewrote application in C.

 -- John Doe <john@doe.com>  Thu, 06 Jul 2017 13:59:26 +0000

hello (2.0.0-1) stretch; urgency=medium

  * Initial packaging work with dpkg-buildpackage.

 -- John Doe <john@doe.com>  Thu, 06 Jul 2017 09:19:24 +0000
~~~

### `debian/compat`

Debhelper has had many releases in the past. To cope with compatibility issues, debhelper requires you to specify a compatibility level through the `debian/compat` file. You can learn more about the different compatibility levels in [the debhelper man page](https://manpages.debian.org/stretch/debhelper/debhelper.7.en.html#COMPATIBILITY_LEVELS), section "Compatibility levels".

Let's use compatibility level 9:

~~~bash
echo 9 > debian/compat
~~~

### `debian/rules`

The rules file must contain:

~~~Makefile
#!/usr/bin/make -f

clean:
	make clean

build:
	make

binary:
	make install DESTDIR=debian/hello
	strip --strip-all debian/hello/usr/bin/hello
	dh_makeshlibs
	dh_gencontrol
	dh_builddeb
~~~

The `clean` and `build` targets are pretty straightforward: they just invoke the application's own build system's Makefile to do the corresponding jobs.

The `binary` target first calls `make install`, but also passes the DESTDIR variable (which the application's own Makefile respects) to ensure that it installs into debian/hello/usr/bin instead of /usr/bin.

Next, it calls `strip` which strips debugging symbols from the `hello` binary. Stripping debugging symbols is a good idea because users are probably never going to debug packaged apps.

Then it calls `dh_makeshlibs` which scans binaries to find out what shared libraries they depend on. The information is used for substituting `${shlibs:Depends}, ${misc:Depends}` in the control file.

Finally, it calls `dh_gencontrol` and `dh_builddeb` to generate our .deb files: `hello_3.0.0_<ARCH>.deb`.

## Building the package

Run:

~~~bash
dpkg-buildpackage -b
~~~

### Examening debhelper's behavior

Curious about what debhelper is doing? Set the environment variable `DH_VERBOSE=1` and will tell you all the commands that it executes under the hood. Let's give it a try:

~~~bash
env DH_VERBOSE=1 dpkg-buildpackage -b
~~~

Here is a part of the output:

~~~
 debian/rules binary                                        <--- (1)
make install DESTDIR=debian/hello                           <--- (2)
make[1]: Entering directory '/host/tutorial-3'
mkdir -p debian/hello/usr/bin
cp hello debian/hello/usr/bin/hello
make[1]: Leaving directory '/host/tutorial-3'
strip --strip-all debian/hello/usr/bin/hello                <--- (3)
dh_makeshlibs                                               <--- (4)
	rm -f debian/hello/DEBIAN/shlibs
dh_gencontrol                                               <--- (5)
	dpkg-gencontrol -phello -ldebian/changelog -Tdebian/hello.substvars -Pdebian/hello
dpkg-gencontrol: warning: Depends field of package hello: unknown substitution variable ${shlibs:Depends}
	chmod 644 debian/hello/DEBIAN/control
	chown 0:0 debian/hello/DEBIAN/control
dh_builddeb                                                 <--- (6)
	dpkg-deb --build debian/hello ..
dpkg-deb: building package `hello' in `../hello_3.0.0-1_amd64.deb'.
 dpkg-genchanges -b >../hello_3.0.0-1_amd64.changes
dpkg-genchanges: binary-only upload (no source code included)
 dpkg-source --after-build tutorial-3
dpkg-buildpackage: binary-only upload (no source included)
~~~

How do you read all this?

 1. Let's begin with the `debian/rules binary` line: this line says that dpkg-buildpackage invokes the debian/rules makefile with the 'binary' target. The lines that follow, indicate what happened inside this target.
 2. The rules makefile calls `make install`. The next few lines that follow are simply `make install`'s output.
 3. The rules makefile calls `strip`.
 4. The rules makefile calls `dh_makeshlib`. The next line shows one of the things that `dh_makeshlib` does, namely removing an `shlibs` file. It also generates a new such file but does not print that.
 5. The rules makefile calls `dh_gencontrol`. The next lines show that it calls `dpkg-gencontrol` under the hood, that dpkg-gencontrol prints a warning (which we can safely ignore) and that `dh_gencontrol` chmods a bunch of files.
 6. The rules makefile calls `dh_builddeb`. We see that it calls `dpkg-deb` and a bunch of other tools under the hood.

## Verifying that it works

When done, you will end up with two .deb files in the parent directory. Install the main one (not the -dbgsym one) and verify that it works:

~~~bash
$ sudo gdebi -n ../hello_3.0.0_<ARCH>.deb
$ hello
hello 3.0.0
~~~

## Conclusion

In this tutorial you have learned how to package an application that requires compilation. It involves:

 * Modifying the `rules` file to call whatever commands are necessary to compile the application and to install it into the package root directory.
 * Modifying the `control` file to add a few packages dependency substitution keywords, build dependencies, and architecture information.

You have also learned what debhelper is, how it relates to the mysterious `control/compat` file, how to work with the `dh_makeshlibs` tool, and how you can see what debhelper is doing. But so far we have only used debhelper as minimally as is necessary to learn how it works. In the next tutorial we will show you how to make full use of debhelper, to the extent that debhelper may look like magic to those who haven't read this tutorial 3.
