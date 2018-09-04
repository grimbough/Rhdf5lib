# Creating hdf5small_cxx.tar.gz

Instructions for editing the hdf5 source down into a reduced version for inclusion the package.  The is just a record of the steps I took, and should be automated in the future if possible.

### Deleted the following folders:
  - /examples
  - /fortran
  - /hl
  - /release_docs
  - /test
  - /testpar
  - /tools
  - /c++/examples
  - /c++/test

### Modified */configure.ac*

- Remove references to the deleted files.  Replace lines 2924 with

```
AC_CONFIG_FILES([src/libhdf5.settings
                 Makefile
                 src/Makefile
                 c++/Makefile
                 c++/src/Makefile
                 c++/src/h5c++])
```
- Comment out lines 3371 - 3379

```
#chmod 755 tools/src/misc/h5cc
#
#if test "X$HDF_FORTRAN" = "Xyes"; then
#  chmod 755 fortran/src/h5fc
#fi
```
- Comment out reference to *fortran/src/H5config_f.inc* on lines 464 & 465

Then run `autoconf` in `/`.

### Modified */c++/Makefile.am*

- Remove references to *test* and *examples* folders on lines 23 and 25 e.g.

```
if BUILD_CXX_CONDITIONAL
   SUBDIRS=src
endif
DIST_SUBDIRS = src
```

### Modified */Makefile.am*

- Remove references to multiple folders that no longer exist on lines 78 - 80 e.g.

```
SUBDIRS = src . $(CXX_DIR)
DIST_SUBDIRS = src . c++
```

- Comment out lines for building the tests, lines 99 - 105.

```
# Make all, tests, and (un)install
#tests:
#	for d in $(SUBDIRS); do                        \
#	  if test $$d != .; then                                        \
#	   (cd $$d && $(MAKE) $(AM_MAKEFLAGS) $@) || exit 1;            \
#	  fi;                                                           \
#	  done
```
run `automake` in `/`

```{bash}
../configure  \
--enable-cxx \
--enable-static \
--disable-shared \
--disable-hl \
--disable-fortran
```

# Modifying szip-2.1.1

### Delete files and folders
  - /autom4te.cache
  - /test
  
### Modify configure.ac  

Remove reference to *test* folder, line 200:

```
AC_CONFIG_FILES([Makefile
                 src/Makefile
                 ])
```
  
### Modify Makefile.in

Remove reference to *test* folder, line 327:
```
SUBDIRS = src
```

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
mkdir /c/hdf5_build/CMake-hdf5-1.10.3/hdf5-1.10.3/build_32
cd /c/hdf5_build/CMake-hdf5-1.10.3/hdf5-1.10.3/build_32
rm -R *
cmake ../ -G "MSYS Makefiles" \
-DSITE_OS_BITS:STRING="32" \
-DCMAKE_C_STANDARD_LIBRARIES="-liberty" \
-DBUILD_SHARED_LIBS:BOOL=ON \
-DHDF5_BUILD_HL_LIB:BOOL=OFF \
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON \
-DBUILD_TESTING:BOOL=OFF \
-DHDF5_BUILD_TOOLS:BOOL=OFF \
-DHDF5_ALLOW_EXTERNAL_SUPPORT:STRING="TGZ" \
-DZLIB_TGZ_NAME:STRING="ZLib.tar.gz" \
-DSZIP_TGZ_NAME:STRING="SZip.tar.gz" \
-DTGZPATH:STRING="/c/hdf5_build/CMake-hdf5-1.10.3/" \
-DCMAKE_BUILD_TYPE:STRING="Release"
cmake --build . 2> stderr.txt
```

### Building 64-bit

```bash
export PATH=/c/Rtools/mingw_64/bin:/c/msys64/mingw64/bin:$PATH
export CPATH=/c/Rtools/mingw_64/x86_64-w64-mingw32/include:/c/Rtools/mingw_64/include:$CPATH
export LD_LIBRARY_PATH=/c/Rtools/mingw_64/x86_64-w64-mingw32/lib:/c/Rtools/mingw_64/lib:$LD_LiBRARY_PATH
mkdir /c/hdf5_build/CMake-hdf5-1.10.3/hdf5-1.10.3/build_64
cd /c/hdf5_build/CMake-hdf5-1.10.3/hdf5-1.10.3/build_64
rm -R *
cmake ../ -G "MSYS Makefiles" \
-DSITE_OS_BITS:STRING="64" \
-DCMAKE_C_STANDARD_LIBRARIES="-liberty" \
-DBUILD_SHARED_LIBS:BOOL=ON \
-DHDF5_BUILD_HL_LIB:BOOL=OFF \
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON \
-DBUILD_TESTING:BOOL=OFF \
-DHDF5_BUILD_TOOLS:BOOL=OFF \
-DHDF5_ALLOW_EXTERNAL_SUPPORT:STRING="TGZ" \
-DZLIB_TGZ_NAME:STRING="ZLib.tar.gz" \
-DSZIP_TGZ_NAME:STRING="SZip.tar.gz" \
-DTGZPATH:STRING="/c/hdf5_build/CMake-hdf5-1.10.3/" \
-DCMAKE_BUILD_TYPE:STRING="Release"
cmake --build . 2> stderr.txt
```

In `src/H5win32defs.h` define `H5open` as `#define HDopen(S,F,M)       _open(S,F|_O_BINARY,M)`

change line 291 from

```diff
- if((fd = HDopen(full_name, O_RDONLY)) < 0)
+ if((fd = HDopen(full_name, O_RDONLY, 0)) < 0)
```
