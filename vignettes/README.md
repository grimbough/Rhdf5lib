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

### Installing *dlfcn.h*

HDF5 has a smal number of calls to functions defined in *dlfcn.h*.  Reading around it seems these don't do anything on Windows, but *configure* doesn't mask them out if you're missing the header and compile fails.  The **Rtools** install doesn't have this library included, so we'll download it in MSYS and copy into our **Rtools** installation.

```{bash}
## install
pacman -S mingw32/mingw-w64-i686-dlfcn mingw64/mingw-w64-x86_64-dlfcn
## copy libraries
cp /c/msys64/mingw64/lib/libdl*.a /c/Rtools/mingw_64/lib/
cp /c/msys64/mingw32/lib/libdl*.a /c/Rtools/mingw_32/lib/
## copy headers
cp /c/msys64/mingw64/include/dlfcn.h /c/Rtools/mingw_64/include/
cp /c/msys64/mingw32/include/dlfcn.h /c/Rtools/mingw_32/include/
```

### Install **perl**

Running make seems to require **perl** so we'll install that too

```{bash}
pacman -S perl
```

## Compiling

### 64 bit

```{bash}
../configure  \
--host=x86_64-w64-mingw32 \
--enable-cxx \
--enable-static \
--disable-shared \
--disable-hl \
--disable-fortran \
--with-zlib=/c/Rtools/mingw_64/x86_64-w64-mingw32/ \
CC=/c/Rtools/mingw_64/bin/gcc.exe \
CXX=/c/Rtools/mingw_64/bin/g++.exe \
CPP=/c/Rtools/mingw_64/bin/cpp.exe \
RANLIB=/c/Rtools/mingw_64/bin/ranlib.exe \
AR=/c/Rtools/mingw_64/bin/ar.exe \
AS=/c/Rtools/mingw_64/bin/as.exe \
DLLTOOL=/c/Rtools/mingw_64/bin/dlltool.exe \
DLLWRAP=/c/Rtools/mingw_64/bin/dllwrap.exe \
LDFLAGS="-liberty" \
CPPFLAGS="-I/c/Rtools/mingw_64/x86_64-w64-mingw32/include -I/c/Rtools/mingw_64/include -L/c/Rtools/mingw_64/x86_64-w64-mingw32/lib -L/c/Rtools/mingw_64/lib"

/c/Rtools/mingw_64/bin/mingw32-make.exe
```

### 32 bit

```{bash}
../configure  \
--host=i686-w64-mingw32 \
--enable-cxx \
--enable-static \
--disable-shared \
--disable-hl \
--disable-fortran \
--with-zlib=/c/Rtools/mingw_32/i686-w64-mingw32/ \
CC=/c/Rtools/mingw_32/bin/gcc.exe \
CXX=/c/Rtools/mingw_32/bin/g++.exe \
CPP=/c/Rtools/mingw_32/bin/cpp.exe \
RANLIB=/c/Rtools/mingw_32/bin/ranlib.exe \
AR=/c/Rtools/mingw_32/bin/ar.exe \
AS=/c/Rtools/mingw_32/bin/as.exe \
DLLTOOL=/c/Rtools/mingw_32/bin/dlltool.exe \
DLLWRAP=/c/Rtools/mingw_32/bin/dllwrap.exe \
LDFLAGS="-liberty" \
CPPFLAGS="-I/c/Rtools/mingw_32/i686-w64-mingw32/include -I/c/Rtools/mingw_32/include -L/c/Rtools/mingw_32/i686-w64-mingw32/lib -L/c/Rtools/mingw_32/lib"

/c/Rtools/mingw_32/bin/mingw32-make.exe
```
 
## CMAKE 

```
pacman -S mingw-w64-x86_64-toolchain
pacman -S mingw-w64-i686-toolchain mingw32/mingw-w64-i686-cmake


export PATH=/c/Rtools/mingw_32/bin:/c/msys64/mingw32/bin:$PATH
export CPATH=/c/Rtools/mingw_32/i686-w64-mingw32/include:/c/Rtools/mingw_32/include:$CPATH
export LD_LIBRARY_PATH=/c/Rtools/mingw_32/i686-w64-mingw32/lib:/c/Rtools/mingw_32/lib:$LD_LiBRARY_PATH
mkdir /c/hdf5_build/cmake/CMake-hdf5-1.8.19/hdf5-1.8.19/build_32
cd /c/hdf5_build/cmake/CMake-hdf5-1.8.19/hdf5-1.8.19/build_32
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
-DTGZPATH:STRING="/c/hdf5_build/cmake/CMake-hdf5-1.8.19/" \
-DCMAKE_BUILD_TYPE:STRING="Release"
cmake --build . 2> stderr.txt
```

```
export PATH=/c/Rtools/mingw_64/bin:/c/msys64/mingw64/bin:$PATH
export CPATH=/c/Rtools/mingw_64/x86_64-w64-mingw32/include:/c/Rtools/mingw_64/include:$CPATH
export LD_LIBRARY_PATH=/c/Rtools/mingw_64/x86_64-w64-mingw32/lib:/c/Rtools/mingw_64/lib:$LD_LiBRARY_PATH
cd /c/hdf5_build/cmake/CMake-hdf5-1.8.19/hdf5-1.8.19/build_zlibbioc2
rm -R *
cmake ../ -G "MSYS Makefiles" \
-DCMAKE_C_STANDARD_LIBRARIES="-liberty" \
-DSITE_OS_BITS:STRING="64" \
-DBUILD_SHARED_LIBS:BOOL=ON \
-DHDF5_BUILD_HL_LIB:BOOL=OFF \
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=OFF \
-DBUILD_TESTING:BOOL=OFF \
-DHDF5_BUILD_TOOLS:BOOL=OFF \
-DZLIB_LIBRARY:FILEPATH="/c/Users/Mike\ Smith/Documents/R/win-library/3.4/zlibbioc/libs/x64/zlib1bioc.dll" \
-DZLIB_INCLUDE_DIR:PATH="/c/Users/Mike\ Smith/Documents/R/win-library/3.4/zlibbioc/include" \
-DCMAKE_BUILD_TYPE:STRING="Release"
cmake --build . 2> stderr.txt
```
