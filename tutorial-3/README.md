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

Most Debian packages delegate almost all work to debhelper where possible, but that doesn't help you understand what's going on. So in this tutorial we will show you how to use debhelper in an as minimal manner as possible; in later tutorials we will show you how to use debhelper to the fullest.

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
	printf("hello 3\n");
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
hello 3
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

   `dpkg-buildpackage` checks whether all Build-Dependencies are installed, and refuses to continue if any is missing. There are even tools out there which will automatically install all Build-Dependencies; you will learn these tools in later tutorials.

 * Changed the "Architecture" field from "all" (package works on all architectures, does not require compilation) to "any" (package can be compiled for any Debian/Ubuntu-supported architecture).

 * Removed the Python dependency.

 * Added two dependencies: `${shlibs:Depends}, ${misc:Depends}`. These are magic keywords that are substituted by `dh_gencontrol`. `dh_gencontrol` scans all the binary files in our package root directory, automatically infers any shared library dependencies that they have, and assigns them to these variables. Our example program is a C program, so it depends on glibc. Indeed, `dh_gencontrol` substitutes these keywords with "glibc".

 * Updated the description.

### `debian/changelog`

We add a new changelog entry to the beginning of the file. The full file looks like this:

~~~
hello (3.0.0) stretch; urgency=medium

  * Rewrote application in C.

 -- John Doe <john@doe.com>  Thu, 06 Jul 2017 13:59:26 +0000

hello (2.0.0) stretch; urgency=medium

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
	dh_strip
	dh_gencontrol
	dh_builddeb
~~~

The `clean` and `build` targets are pretty straightforward: they just invoke the application's own build system's Makefile to do the corresponding jobs.

The `binary` target first calls `make install`, but also passes the DESTDIR variable (which the application's own Makefile respects) to ensure that it installs into debian/hello3/usr/bin instead of /usr/bin.

Next, it calls `dh_strip`, which scans the package root directory for binary files and extracts their debugging symbols into external files. Here is a surprise: calling `dh_strip` is actually *required* when packaging C applications or other applications whose binaries can contain debugging symbols. You will learn why in subsection "Debugging symbol packages".

Finally, it calls `dh_gencontrol` and `dh_builddeb` to generate two .deb package files: `hello_3.0.0_<ARCH>.deb` and `hello-dbgsym_3.0.0_<ARCH>.deb`.

## Debugging symbol packages

The Debian packaging tooling require debugging symbols to be extracted from the binaries into separate `-dbgsym` subpackages. For example bash's debug symbols are stored in a package named bash-dbgsym. Normal users won't ever debug your applications, but sometimes it is necessary, so it makes sense to split debugging symbols into a separate package.

`dh_builddeb` will automatically try to generate to the `-dbgsym` subpackage if it detects any binaries with debugging symbols. It expects the debugging symbols to already have been extracted into the following directory: `debian/.debhelper/hello/dbgsym-root`. And that is exactly what `dh_strip` did. If we omit the call to `dh_strip` then `dh_builddeb` will fail.

This illustrates that **some Debhelper tools depend on other Debhelper tools**. This is why most Debian packages delegate as much work as possible to debhelper, instead of only picking specific parts of debhelper, which is what we did in this tutorial.

## Building the package

~~~bash
dpkg-buildpackage -b
~~~

### What is debhelper doing under the hood?

Curious about what debhelper is doing? Set the environment variable `DH_VERBOSE=1` and will tell you all the commands that it executes under the hood. Let's give it a try:

~~~bash
env DH_VERBOSE=1 dpkg-buildpackage -b
~~~

Here is a part of the output:

~~~
dh_strip
	install -d debian/.debhelper/hello/dbgsym-root/usr/lib/debug/.build-id/d5
	objcopy --only-keep-debug --compress-debug-sections debian/hello/usr/bin/hello debian/.debhelper/hello/dbgsym-root/usr/lib/debug/.build-id/d5/2d3d6a2dc05d9beac28af2f7cc98ea5e1ca12d.debug
	chmod 0644 -- debian/.debhelper/hello/dbgsym-root/usr/lib/debug/.build-id/d5/2d3d6a2dc05d9beac28af2f7cc98ea5e1ca12d.debug
	chown 0:0 -- debian/.debhelper/hello/dbgsym-root/usr/lib/debug/.build-id/d5/2d3d6a2dc05d9beac28af2f7cc98ea5e1ca12d.debug
	strip --remove-section=.comment --remove-section=.note debian/hello/usr/bin/hello
	objcopy --add-gnu-debuglink debian/.debhelper/hello/dbgsym-root/usr/lib/debug/.build-id/d5/2d3d6a2dc05d9beac28af2f7cc98ea5e1ca12d.debug debian/hello/usr/bin/hello
	install -d debian/.debhelper/hello/dbgsym-root/usr/share/doc
	ln -s hello debian/.debhelper/hello/dbgsym-root/usr/share/doc/hello-dbgsym
dh_gencontrol
	install -d debian/hello/DEBIAN
	echo misc:Depends= >> debian/hello.substvars
	echo misc:Pre-Depends= >> debian/hello.substvars
	install -d debian/.debhelper/hello/dbgsym-root/DEBIAN
	dpkg-gencontrol -phello -ldebian/changelog -Tdebian/hello.substvars -Pdebian/.debhelper/hello/dbgsym-root -UPre-Depends -URecommends -USuggests -UEnhances -UProvides -UEssential -UConflicts -DPriority=extra -DAuto-Built-Package=debug-symbols -DPackage=hello-dbgsym "-DDepends=hello (= \${binary:Version})" "-DDescription=Debug symbols for hello" -DBuild-Ids=d52d3d6a2dc05d9beac28af2f7cc98ea5e1ca12d -DSection=debug -UMulti-Arch -UReplaces -UBreaks
dpkg-gencontrol: warning: Depends field of package hello: unknown substitution variable ${shlibs:Depends}
	chmod 0644 -- debian/.debhelper/hello/dbgsym-root/DEBIAN/control
	chown 0:0 -- debian/.debhelper/hello/dbgsym-root/DEBIAN/control
	dpkg-gencontrol -phello -ldebian/changelog -Tdebian/hello.substvars -Pdebian/hello
dpkg-gencontrol: warning: Depends field of package hello: unknown substitution variable ${shlibs:Depends}
	chmod 0644 -- debian/hello/DEBIAN/control
	chown 0:0 -- debian/hello/DEBIAN/control
dh_builddeb
	dpkg-deb -z1 -Zxz -Sextreme --build debian/.debhelper/hello/dbgsym-root ..
~~~

As you can see, `dh_strip` calls `objcopy` and `strip` to extract debugging symbols to external files.

`dh_gencontrol` uses `dpkg-gencontrol` under the hood to to create `debian/hello/DEBIAN/control`.

`dh_debbuild` uses `dpkg-deb` under the hood.

## Verifying that it works

When done, you will end up with two .deb files in the parent directory. Install the main one (not the -dbgsym one) and verify that it works:

~~~bash
$ sudo apt install -y ../hello_3.0.0_<ARCH>.deb
$ hello
hello 3
~~~

## Conclusion

In this tutorial you have learned how to package an application that requires compilation. It involves:

 * Modifying the `rules` file to call whatever commands are necessary to compile the application and to install it into the package root directory.
 * Modifying the `control` file to add a few magic pakcages dependency keywords, build dependencies, and architecture information.

You have also learned what debhelper is, how it relates to the mysterious `control/compat` file, and how you can see what debhelper is doing.
