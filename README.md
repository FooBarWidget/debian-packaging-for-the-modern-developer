# Debian Packaging For The Modern Developer (DPMD)

Welcome to DPMD

**Table of contents**

 * Why should DevOps people learn Debian packaging?
 * Why should open source application developers learn Debian packaging?
 * Welcome to DPMD
 * Tutorials
 * Guides
 * References

---

## Why should DevOps people learn Debian packaging?

In this day and age where new paradigms and languages such as DevOps, Node.js, Ruby, Go and next-gen JVM languages reign surpreme, people are constantly looking for the best way to manage their application and infrastructure deployments. People are flocking to Docker, or to custom schemes such as uploading binary tarballs to the server or even compiling on the server. But Docker requires large infrastructure overhauls as well as a lot of staff retraining. Once you start investing efforts towards that, it's hard to turn back even if there are more suitable alternatives. Binary tarballs are hard to manage, while compiling on the server is slow. Plus, none of these approaches have a good answer to automatic (security) updates.

But there may be a more suitable alternative; an ancient power which has been overlooked by many, waiting to be harnessed by you. If you use Debian or Ubuntu, then you can manage your applications by packaging them as Debian packages.

From the perspective of sysadmins who *use* Debian packages, they are tried and true: they are very reliable, they are well-understood by the industry and the community, there is a lot of tooling available for managing packages and they support automatic security updates.

Debian packages are tried and true: they are very reliable and, from the perspective of a user, are a joy to use. Unlike Docker and plain application directory tarballs, Debian packages support automatic updates.

## Why should open source application developers learn Debian packaging?

You are publishing source code already. Plus, why should you publish Debian packages yourself instead of relying on distribution packagers?

Once upon a time, users were not shy about compiling and getting software directly from the author. But user experiences and expectations are changing: a lot of users nowadays struggle with compilation, and most of them get their software through binaries. And distribution packagers are notoriously slow: by the time they've published a package, their version already lags behind the latest release by a year. This may hurt your reputation: users are not experiencing the latest and greatest, or leave being frustrated that they can't get the latest version working. They may also generate needless support requests from users who are confused about the source installation process, draining time and energy from you which you could spend on more useful endeavors.

Imagine a future where users get the latest version as soon as you publish the source code. Users stay happy, secure (through automatic updates), and tell teach about your great contributions to the world. Many popular open source projects nowadays publish Debian packages directly. Examples include Node.js, Nginx, Jenkins and Phusion Passenger. So join us in this quest to give users the best.

## Welcome to DPMD

Making Debian packages is somewhat of an arcane art. The learning curve is steep and the tooling is incoherent and non-intuitive. Most of the documentation out there make huge mental leaps, leaving many readers in a confused state where they only half-understand what's going on; or are written from the perspective that you are a third-party or distribution packager who packages an open source.

That is where we come in. DPMD is authored by [Phusion](https://www.phusion.nl/), who has been publishing Debian packages for [the Passenger application server](https://www.phusionpassenger.com/) since 2014. We are DevOps people and application developers like you, so we know the pains of learning Debian packaging.

DPMD consists of tutorials that teach you step-by-step how all the different concepts of Debian packaging fit together. You will understand every aspect in sufficient detail so that you can be confident and quick, and so that when a problem occurs you know how to fix it. DPMD provides practical tips on how to package more efficiently and effectively.

## Tutorials

### Preparation

 * Required prior knowledge, preparing the tutorial environment
 * Debian packaging concepts and workflow in a nutshell

### Basics

 * Tutorial 1: building the simplest Debian binary package
 * Tutorial 2: building a binary package using dpkg-buildpackage
 * Tutorial 3: packaging a compiled application, introducing debhelper
 * Tutorial 4: making full use of debhelper
 * Tutorial 5: the debhelper pipeline and customizing debhelper steps

### Intermediate

 * Tutorial 6: source packages
 * Tutorial 7: subpackages and .install files
 * Tutorial 8: multi-user file permissions and the fakeroot tool
 * Tutorial 9: packaging distribution-specific files

### Advanced

 * Tutorial 10: system integration files: systemd services, Apache configs, man pages, crontabs and more
 * Tutorial 11: building packages for multiple distributions and architectures with pbuilder-dist
 * Tutorial 12: hosting packages and an APT repository on PackageCloud

## Guides

 * Dealing with multiple distribution versions and architectures
 * Patching applications specifically for a distribution
 * Submitting packages for inclusion in Debian or Ubuntu's repositories

## References

 * [Debian packaging tutorial by Lucas Nussbaum](https://www.debian.org/doc/manuals/packaging-tutorial/packaging-tutorial.en.pdf)
 * [Debian New Maintainers' Guide](https://www.debian.org/doc/manuals/maint-guide/)
 * [Debian New Maintainer's Guide: Other files under the `debian` directory](https://www.debian.org/doc/manuals/maint-guide/dother.en.html)
 * [Debian Policy Manual](https://www.debian.org/doc/debian-policy/)
 * [Debian Developer's Reference: Best Packaging Practices](https://www.debian.org/doc/manuals/developers-reference/ch06.en.html)
 * [Debian Developer's Reference: Overview of Debian Maintainer Tools](https://www.debian.org/doc/manuals/developers-reference/apa.en.html)
 * [debhelper man page](https://manpages.debian.org/stretch/debhelper/debhelper.7.en.html)
 * [debhelper dh overrides](https://joeyh.name/blog/entry/debhelper_dh_overrides/)
