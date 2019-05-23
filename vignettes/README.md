# Creating hdf5small_cxx.tar.gz

Instructions for creating the source tarball can now be found in [downloadHDF5.Rmd](downloadHDF5.Rmd).

# Compiling on Windows

Compiling on Windows while using the Rtools toolchain took a number of attempts.  This is a current 'best memory' of tħe required steps to build the versions of `libhdf5.a` and `libhdf5_cpp.a` shipped with the package.  The instructions should be tested on a clean Windows machine and refined in the future.

## Required software

Install both of these using the GUI installer provided.  I'm going to assume they're in the default locations for all further steps.

- Rtools (https://cran.r-project.org/bin/windows/Rtools/)
- MSYS2 (http://www.msys2.org/)

## CMAKE 

I was unable to get `./configure` to successfully build the libraries on Windows.  It seems possible to complete the compilation, but the resulting libraries still don't work as exepcted.  Hence we use `cmake` as suggested in the HDF5 documentation.  The source zip file was obtained from `https://www.hdfgroup.org/downloads/hdf5/source-code/#cmake`

First, we make sure we have the required tools to build both 32 & 64-bit versions.

```
pacman -Syu ##upgrade msys, pacman & repos
pacman -S mingw-w64-x86_64-toolchain mingw64/mingw-w64-x86_64-cmake
pacman -S mingw-w64-i686-toolchain mingw32/mingw-w64-i686-cmake
#pacman -U http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-rhash-1.3.6-2-any.pkg.tar.xz
#pacman -U http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-cmake-3.12.1-1-any.pkg.tar.xz
#pacman -U http://repo.msys2.org/mingw/i686/mingw-w64-i686-rhash-1.3.6-2-any.pkg.tar.xz
#pacman -U http://repo.msys2.org/mingw/i686/mingw-w64-i686-cmake-3.12.1-1-any.pkg.tar.xz
```

### Building 32-bit

```bash
export PATH=/c/Rtools/mingw_32/bin:/c/msys64/mingw32/bin:$PATH
export CPATH=/c/Rtools/mingw_32/i686-w64-mingw32/include:/c/Rtools/mingw_32/include:$CPATH
export LD_LIBRARY_PATH=/c/Rtools/mingw_32/i686-w64-mingw32/lib:/c/Rtools/mingw_32/lib:$LD_LiBRARY_PATH
mkdir /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_32
cd /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_32
rm -R *
cmake ../ -G "MSYS Makefiles" \
-DSITE_OS_BITS:STRING="32" \
-DCMAKE_C_STANDARD_LIBRARIES="-liberty" \
-DBUILD_SHARED_LIBS:BOOL=ON \
-DHDF5_BUILD_HL_LIB:BOOL=ON \
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON \
-DBUILD_TESTING:BOOL=OFF \
-DHDF5_BUILD_TOOLS:BOOL=OFF \
-DHDF5_ALLOW_EXTERNAL_SUPPORT:STRING="TGZ" \
-DZLIB_TGZ_NAME:STRING="ZLib.tar.gz" \
-DSZIP_TGZ_NAME:STRING="SZip.tar.gz" \
-DTGZPATH:STRING="/c/hdf5_build/CMake-hdf5-1.10.5/" \
-DCMAKE_BUILD_TYPE:STRING="Release"
cmake --build . 2> stderr.txt
```

### Building 64-bit

```bash
export PATH=/c/Rtools/mingw_64/bin:/c/msys64/mingw64/bin:$PATH
export CPATH=/c/Rtools/mingw_64/x86_64-w64-mingw32/include:/c/Rtools/mingw_64/include:$CPATH
export LD_LIBRARY_PATH=/c/Rtools/mingw_64/x86_64-w64-mingw32/lib:/c/Rtools/mingw_64/lib:$LD_LiBRARY_PATH
mkdir /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_64
cd /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_64
rm -R *
cmake ../ -G "MSYS Makefiles" \
-DSITE_OS_BITS:STRING="64" \
-DCMAKE_C_STANDARD_LIBRARIES="-liberty" \
-DBUILD_SHARED_LIBS:BOOL=ON \
-DHDF5_BUILD_HL_LIB:BOOL=ON \
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON \
-DBUILD_TESTING:BOOL=OFF \
-DHDF5_BUILD_TOOLS:BOOL=OFF \
-DHDF5_ALLOW_EXTERNAL_SUPPORT:STRING="TGZ" \
-DZLIB_TGZ_NAME:STRING="ZLib.tar.gz" \
-DSZIP_TGZ_NAME:STRING="SZip.tar.gz" \
-DTGZPATH:STRING="/c/hdf5_build/CMake-hdf5-1.10.5/" \
-DCMAKE_BUILD_TYPE:STRING="Release"
cmake --build . 2> stderr.txt
```

In `src/H5win32defs.h` define `H5open` as `#define HDopen(S,F,M)       _open(S,F|_O_BINARY,M)`

change line 291 H5Defl.h from

```diff
- if((fd = HDopen(full_name, O_RDONLY)) < 0)
+ if((fd = HDopen(full_name, O_RDONLY, 0)) < 0)
```

```
version=1.10.5
cd /c/hdf5_build/CMake-hdf5-${version}
mkdir /c/hdf5_build/CMake-hdf5-${version}/hdf5
mkdir /c/hdf5_build/CMake-hdf5-${version}/hdf5/c++
mkdir /c/hdf5_build/CMake-hdf5-${version}/hdf5/hl
cp /c/hdf5_build/CMake-hdf5-${version}/hdf5-${version}/src/*.h /c/hdf5_build/CMake-hdf5-${version}/hdf5/
cp /c/hdf5_build/CMake-hdf5-${version}/hdf5-${version}/c++/src/*.h /c/hdf5_build/CMake-hdf5-${version}/hdf5/c++/
cp /c/hdf5_build/CMake-hdf5-${version}/hdf5-${version}/hl/src/*.h /c/hdf5_build/CMake-hdf5-${version}/hdf5/hl/
cp /c/hdf5_build/CMake-hdf5-${version}/hdf5-${version}/hl/c++/src/*.h /c/hdf5_build/CMake-hdf5-${version}/hdf5/hl/
cp /c/hdf5_build/CMake-hdf5-${version}/hdf5-${version}/build_32/*.h /c/hdf5_build/CMake-hdf5-${version}/hdf5/
tar cf - hdf5 | gzip -6 > hdf5_headers_${version}.tar.gz
```

```
DIR32="${HOME}/Code/bioconductor/Rhdf5lib/src/winlib/i386/"
cp /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_32/bin/liblibhdf5.a "${DIR32}"libhdf5.a 
cp /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_32/bin/liblibhdf5_cpp.a "${DIR32}"libhdf5_cpp.a
cp /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_32/bin/liblibhdf5_hl.a "${DIR32}"libhdf5_hl.a
cp /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_32/bin/liblibhdf5_hl_cpp.a "${DIR32}"libhdf5_hl_cpp.a

DIR64="${HOME}/Code/bioconductor/Rhdf5lib/src/winlib/x64/"
cp /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_64/bin/liblibhdf5.a "${DIR64}"libhdf5.a 
cp /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_64/bin/liblibhdf5_cpp.a "${DIR64}"libhdf5_cpp.a
cp /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_64/bin/liblibhdf5_hl.a "${DIR64}"libhdf5_hl.a
cp /c/hdf5_build/CMake-hdf5-1.10.5/hdf5-1.10.5/build_64/bin/liblibhdf5_hl_cpp.a "${DIR64}"libhdf5_hl_cpp.a