#!/bin/bash

curl -L https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.7/src/hdf5-1.10.7.tar.bz2 -o hdf5.tar.bz2
rm -rf vendor/hdf5
mkdir -p vendor/hdf5
# strip-components is "dangerous" because it we go too deep, we mess up the entire folder structure.
# If the compilation suddenly fails for apparently no reason, check this.
tar -xf hdf5.tar.bz2 -C vendor/hdf5 --strip-components=1
rm hdf5.tar.bz2

rm -rf vendor/hdf5/.git
rm -rf vendor/hdf5/.github
rm -rf vendor/hdf5/bin
rm -rf vendor/hdf5/doc
rm -rf vendor/hdf5/doxygen
rm -rf vendor/hdf5/examples
rm -rf vendor/hdf5/fortran
rm -rf vendor/hdf5/java
rm -rf vendor/hdf5/m4
rm -rf vendor/hdf5/release_docs
rm -rf vendor/hdf5/test
rm -rf vendor/hdf5/testpar
rm -rf vendor/hdf5/tools
rm -rf vendor/hdf5/utils

rm -rf vendor/hdf5/hl/examples
rm -rf vendor/hdf5/hl/fortran
rm -rf vendor/hdf5/hl/test
rm -rf vendor/hdf5/hl/tools

rm -rf vendor/hdf5/c++/examples
rm -rf vendor/hdf5/c++/test
