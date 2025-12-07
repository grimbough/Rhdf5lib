#!/bin/bash

VERSION=2.0.0
curl -L https://github.com/HDFGroup/hdf5/releases/download/${VERSION}/hdf5-${VERSION}.tar.gz -o hdf5.tar.gz
tar -xf hdf5.tar.gz
rm hdf5.tar.gz

rm -rf hdf5
mv hdf5-${VERSION} hdf5

rm -rf hdf5/test
rm -rf hdf5/testpar
rm -rf hdf5/HDF5Examples
rm -rf hdf5/doxygen
rm -rf hdf5/java
rm -rf hdf5/fortran
rm -rf hdf5/tools
rm -rf hdf5/bin
rm -rf hdf5/release_docs
rm -rf hdf5/utils
rm -rf hdf5/hl/fortran
rm -rf hdf5/hl/test
rm -rf hdf5/hl/tools
rm -rf hdf5/c++/test
