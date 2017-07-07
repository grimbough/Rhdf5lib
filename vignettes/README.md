# Creating hdf5small_cxx.tar.gz

Instructions for editing the hdf5 source down into a reduced version for inclusion the package.  The is just a record of the steps I took, and should be automated in the future if possible.

### Deleted the following folders:
  - /examples
  - /fortran
  - /hl
  - /java
  - /release_docs
  - /test
  - /testpar
  - /tools
  - /c++/examples
  - /c++/test

### Modified */configure.ac*

- Remove references to the deleted files.  Replace lines 3355 - 3472 with

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

