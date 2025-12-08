#!/bin/bash

VERSION=2.0.0
curl -L https://github.com/HDFGroup/hdf5/releases/download/${VERSION}/hdf5-${VERSION}.tar.gz -o hdf5.tar.gz
tar -xf hdf5.tar.gz
rm hdf5.tar.gz

rm -rf vendor/hdf5
mv hdf5-${VERSION} vendor/hdf5

rm -rf vendor/hdf5/test
rm -rf vendor/hdf5/testpar
rm -rf vendor/hdf5/HDF5Examples
rm -rf vendor/hdf5/doxygen
rm -rf vendor/hdf5/java
rm -rf vendor/hdf5/fortran
rm -rf vendor/hdf5/tools
rm -rf vendor/hdf5/bin
rm -rf vendor/hdf5/release_docs
rm -rf vendor/hdf5/utils
rm -rf vendor/hdf5/hl/fortran
rm -rf vendor/hdf5/hl/test
rm -rf vendor/hdf5/hl/tools
rm -rf vendor/hdf5/c++/test
