# Process this file with autoconf to produce a configure script.
# author: Mike L. Smith (grimbough@gmail.com)

AC_PREREQ([2.65])
AC_INIT([Rhdf5lib], [1.13], [grimbough@gmail.com])
AC_CONFIG_SRCDIR([src])

m4_include([m4/ax_check_compile_flag.m4])

# Check the compiler configured with R
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  echo "could not determine R_HOME"
  exit 1
fi

## identify build tools
CC=`"${R_HOME}/bin/R" CMD config CC`
AC_SUBST(CC)
AC_SUBST(CXX, `"${R_HOME}/bin/R" CMD config CXX`)
AC_SUBST(MAKE, `"${R_HOME}/bin/R" CMD config MAKE`)
AC_SUBST(RANLIB, `"${R_HOME}/bin/R" CMD config RANLIB`)
AC_SUBST(AR, `"${R_HOME}/bin/R" CMD config AR`)

dnl Checks for programs.
AC_PROG_CC
AC_PROG_CXX

dnl identify compiler flags
CFLAGS=`"${R_HOME}/bin/R" CMD config CFLAGS`
CPICFLAGS=`"${R_HOME}/bin/R" CMD config CPICFLAGS`
CXXFLAGS=`"${R_HOME}/bin/R" CMD config CXXFLAGS`
CXXPICFLAGS=`"${R_HOME}/bin/R" CMD config CXXPICFLAGS`
CPPFLAGS=`"${R_HOME}/bin/R" CMD config CPPFLAGS`

###########################

CC_BASENAME="`echo $CC | cut -f1 -d' '`"
echo "COMPILER = $CC_BASENAME"

dnl hdf5 spews loads of errors.  Use -w to suppress these if we're using GCC
if test "X$CC_BASENAME" = "Xgcc"; then
  AX_CHECK_COMPILE_FLAG([-w], [CFLAGS="$CFLAGS -w"; CXXFLAGS="-w $CXXFLAGS"])
fi

if test "X$CC_BASENAME" = "Xclang"; then
  AX_CHECK_COMPILE_FLAG([-w], [CFLAGS="$CFLAGS -w"; CXXFLAGS="-w $CXXFLAGS"])
fi

###########################

dnl remove LTO compiler flags if requested
AC_ARG_ENABLE([lto])
AS_IF([test "x$enable_lto" = "xno"], [
  CFLAGS=`echo ${CFLAGS} | sed 's/-flto//g'`
  CXXFLAGS=`echo ${CXXFLAGS} | sed 's/-flto//g'`
])

###########################

AC_MSG_CHECKING([whether to use -Wl,-rpath setting])
AC_ARG_ENABLE([sharedlib-rpath],
              [AS_HELP_STRING([--disable-sharedlib-rpath],
               [Disable use of the '-Wl,-rpath' linker option])],
              [ if test "x$enableval" = "xyes" ; then
                SHAREDLIB_RPATH="--enable-sharedlib-rpath"
                AC_MSG_RESULT([yes])
              elif test "x$enableval" = "xno" ; then
                SHAREDLIB_RPATH="--disable-sharedlib-rpath"
                AC_MSG_RESULT([no])
              else
                echo
                echo "Error!"
                echo "rpath code didn't work!"
                exit -1
             fi],
             [ SHAREDLIB_RPATH="--enable-sharedlib-rpath"
               AC_MSG_RESULT([yes]) ]
)

############################


### 'checking for zlib... ';
AC_ARG_WITH([zlib],
            [AS_HELP_STRING([--with-zlib=DIR],
                            [Use zlib library for external deflate I/O
                             filter [default=yes]])],
            [],
            [withval=yes])

case $withval in
  yes)
    HAVE_ZLIB="yes"
    AC_CHECK_HEADERS([zlib.h], [ZLIB_HOME="yes"], [unset HAVE_ZLIB], [AC_INCLUDES_DEFAULT $CFLAGS $CXXFLAGS])
    if test -z "$HAVE_ZLIB"; then
        AC_MSG_ERROR([couldn't find zlib library.  
        Please specify a location using --with-zlib=/path/to/zlib])
    fi
    ZLIB_LIB_PATH=""
    ZLIB_INCLUDE_PATH=""
    ;;
  no)
    AC_MSG_ERROR([zlib is required for Rhdf5lib])
    ;;
  *)
    HAVE_ZLIB="yes"
    ## return FALSE if $withval is empty
    if test -n "$withval"; then
      ZLIB_HOME="$withval"
      if test ! -f "${ZLIB_HOME}/include/zlib.h"; then
        AC_MSG_ERROR([zlib is required but not found in ${ZLIB_HOME}])
      fi
    else
      AC_MSG_ERROR([zlib is required but no path specified])
    fi
    ZLIB_LIB_PATH="-L${ZLIB_HOME}/lib/"
    ZLIB_INCLUDE_PATH="-I${ZLIB_HOME}/include/"
    ;;
esac

###########################################

HAVE_SZLIB="yes"
AC_CHECK_HEADERS([szlib.h], [HAVE_SZLIB_H="yes"], [unset HAVE_SZLIB])
if test "x$HAVE_SZLIB" = "xyes" -a "x$HAVE_SZLIB_H" = "xyes"; then
  AC_CHECK_LIB([sz], [SZ_BufftoBuffCompress],, [unset HAVE_SZLIB])
fi

dnl if there's not a system install of szip build our own version
if test -z "$HAVE_SZLIB"; then
  AC_SUBST(REQUIRE_SZIP, build-szip)
  SZIP_HOME=`pwd -P`/src/hdf5/libaec-1.0.4/build/szip
  AC_SUBST(SZIP_HOME, ${SZIP_HOME})
  COPY_SZIP=copy-szip
  SZIP_LIB='"${USER_LIB_DIR}libsz.a" "${USER_LIB_DIR}libaec.a"'
else
  AC_SUBST(SZIP_HOME, yes)
  CP_SZIP=""
  SZIP_LIB="-lsz"
fi


AC_SUBST(SZIP_LIB)
AC_SUBST(COPY_SZIP)

#############################################

ROS3_VFD=yes
if test "X$ROS3_VFD" = "Xyes"; then
    AC_CHECK_HEADERS([curl/curl.h],, [unset ROS3_VFD])
    AC_CHECK_HEADERS([openssl/evp.h],, [unset ROS3_VFD])
    AC_CHECK_HEADERS([openssl/hmac.h],, [unset ROS3_VFD])
    AC_CHECK_HEADERS([openssl/sha.h],, [unset ROS3_VFD])
    if test "X$ROS3_VFD" = "Xyes"; then
        AC_CHECK_LIB([curl], [curl_global_init],, [unset ROS3_VFD])
        AC_CHECK_LIB([crypto], [EVP_sha256],, [unset ROS3_VFD])
    fi
    if test "X$ROS3_VFD" = "Xyes"; then
        WITH_S3_VFD="--enable-ros3-vfd"
    else
        WITH_S3_VFD="--enable-ros3-vfd=no"
    fi
fi
echo "S3_VFD=${WITH_S3_VFD}"

#############################################

#untar the lib
BASEPBNAME="hdf5"
PBTGZNAME=hdf5small_cxx_hl_1.10.7.tar.gz

if test -d src/${BASEPBNAME}; then 
  EXTRACT_SOURCE=""
  BUILD_HDF5=""
else   
  EXTRACT_SOURCE=extract-source
  BUILD_HDF5=build-hdf5
fi

AC_SUBST(EXTRACT_SOURCE)
AC_SUBST(BUILD_HDF5)

dnl update compiler flags
AC_SUBST(CFLAGS)
AC_SUBST(CPICFLAGS, ${CPICFLAGS})
AC_SUBST(CXXFLAGS, ${CXXFLAGS})
AC_SUBST(CXXPICFLAGS, ${CXXPICFLAGS})
AC_SUBST(CPPFLAGS)

dnl HDF5 building options
AC_SUBST(ZLIB_HOME, ${ZLIB_HOME})
AC_SUBST(SZIP_HOME, ${SZIP_HOME})
AC_SUBST(WITH_S3_VFD)
AC_SUBST(SHAREDLIB_RPATH)

#update variables in Makevars
HDF5_INCLUDE="${BASEPBNAME}/src"
HDF5_CXX_INCLUDE="${BASEPBNAME}/c++/src"
HDF5_HL_INCLUDE="${BASEPBNAME}/hl/src"
HDF5_HL_CXX_INCLUDE="${BASEPBNAME}/hl/c++/src"
AC_SUBST(HDF5_INCLUDE)
AC_SUBST(HDF5_CXX_INCLUDE)
AC_SUBST(HDF5_HL_INCLUDE)
AC_SUBST(HDF5_HL_CXX_INCLUDE)

HDF5_LIB="${BASEPBNAME}/src/.libs/libhdf5.a"
HDF5_CXX_LIB="${BASEPBNAME}/c++/src/.libs/libhdf5_cpp.a"
HDF5_HL_LIB="${BASEPBNAME}/hl/src/.libs/libhdf5_hl.a"
HDF5_HL_CXX_LIB="${BASEPBNAME}/hl/c++/src/.libs/libhdf5_hl_cpp.a"

AC_SUBST(HDF5_LIB)
AC_SUBST(HDF5_CXX_LIB)
AC_SUBST(HDF5_HL_LIB)
AC_SUBST(HDF5_HL_CXX_LIB)
AC_SUBST(ZLIB_HOME)
AC_SUBST(ZLIB_LIB)
AC_SUBST(ZLIB_INCLUDE)

AC_CONFIG_FILES([src/Makevars])

AC_OUTPUT
