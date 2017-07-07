#!/bin/bash
set -e
cd "$(dirname "$0")"
set -x
rm -rf hello* \
	tutorial-1/packageroot/usr \
	tutorial-1/*.deb \
	tutorial-3/hello \
	*/debian/.debhelper */debian/files */debian/hello* */debian/debhelper*
