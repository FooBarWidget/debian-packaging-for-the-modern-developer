# Tutorial 1: building the simplest Debian binary package

So you are a Debian/Ubuntu user. You search for a package with `apt-cache search`. You install a package with `apt-get install`. You already intuitively know these:

 * Packages contain basic metadata such as names and descriptions.
 * Packages may have dependencies.
 * Packages contain files.

Indeed. A Debian package -- a .deb file -- is sort of like a tar.gz or zip file containing **metadata** and **files**. It's not actually a tar.gz or zip: the format is [ar](https://en.wikipedia.org/wiki/Ar_(Unix)) although that's not important.

Let's say you have a hello world application written in Python. It's only job is to print "hello 1":

~~~python
#!/usr/bin/env python
print("hello 1")
~~~

Let's build a simple package for this application, using as few tools and concepts as possible. This is not the proper way to build a package, but it helps you understand what a package is.

First, create a directory for this tutorial and place the above application in `hello1.py`:

~~~bash
mkdir tutorial-1
cd tutorial-1
editor hello1.py   # put the above source code in this file
chmod +x hello1.py
~~~

Now that we have an application, let's build a package. The simplest application that builds a package is `dpkg-deb`. It accepts a directory containing package metadata files and content files. Let's create this directory. We call it `packageroot` but it can have any name.

~~~bash
mkdir packageroot
~~~

The package metadata must live in a file called `DEBIAN/control` under the package root directory. Let's create it:

~~~bash
mkdir packageroot/DEBIAN
editor packageroot/control
~~~

This is what `DEBIAN/control` should contain:

~~~
Package: hello1
Version: 1.0.0
Architecture: all
Maintainer: John Doe <john@doe.com>
Depends: python
Description: John's first hello package
 John's first hello package is written in Python
 and prints "hello 1".
 .
 It is awesome.
~~~

These are the meanings of the field:

 * "Package" specifies the package name.
 * "Version" specifies the package version number.
 * "Architecture" specifies on which computer architectures this package is installable. Since Python apps themselves are platform-independent, we specify "all". But if we were packaging a C program, then this could also contain the name of a specific architecture such as "amd64" (Debian's name for x86_64) or "i386".
 * "Maintainer" specifies who maintains this package.
 * "Depends" is a comma-separated string that specifies this package's dependencies.
 * "Description" contains a summary on the first line, and a more verbose description on subsequent lines. The summary is what you see in `apt-cache search` while the more verbose description is what you see in APT GUIs such as the Ubuntu App Store or Aptitude.

   Note: the verbose description must be prefixed with a single space! And empty lines must contain a single dot character.

Next, let's define the package contents. All files under the package root directory, except for `DEBIAN`, is considered part of the content. We want hello1.py to be installed as /usr/bin/hello1.py, so:

~~~bash
mkdir -p packageroot/usr/bin
cp hello1.py packageroot/usr/bin/
~~~

Now that the package root directory is finished, we turn it into a .deb file:

~~~bash
dpkg-deb -b packageroot hello1_1.0.0_all.deb
~~~

Success! You can now install the .deb file and verify that it works:

~~~
$ sudo apt install -y ./hello1_1.0.0_all.deb
$ hello1.py
hello 1
~~~
