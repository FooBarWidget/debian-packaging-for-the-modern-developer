#!/bin/bash
set -e

echo "Creating packageroot..."
rm -rf packageroot
mkdir packageroot
cp -R debian packageroot/DEBIAN
mkdir -p packageroot/usr/bin
cp hello1.py packageroot/usr/bin/
echo "Done."

echo
echo "Packageroot now contains:"
find packageroot

echo
echo "Creating .deb file..."
dpkg-deb -b packageroot hello1_1.0.0_all.deb
