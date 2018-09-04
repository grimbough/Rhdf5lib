# Process this file with autoconf to produce a configure script.
# author: Mike Smith (mike.smith@embl.de)

AC_PREREQ([2.65])
AC_INIT([Rhdf5lib], [0.99.13], [mike.smith@embl.de])
AC_CONFIG_SRCDIR([src])

# Check the compiler configured with R
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  echo "could not determine R_HOME"
  exit 1
fi

CC=`"${R_HOME}/bin/R" CMD config CC`
CFLAGS=`"${R_HOME}/bin/R" CMD config CFLAGS`
CXX=`"${R_HOME}/bin/R" CMD config CXX`
CXXFLAGS=`"${R_HOME}/bin/R" CMD config CXXFLAGS`
F77=`"${R_HOME}/bin/R" CMD config F77`
MAKE=`"${R_HOME}/bin/R" CMD config MAKE`
AC_LANG(C++)

# Checks for programs.
AC_PROG_CC
AC_PROG_CXX

#untar the lib
BASEPBNAME="hdf5"
PBTGZNAME=hdf5small_cxx_1.10.3.tar.gz
cd src
if test -d ./${BASEPBNAME}; then 
	echo 'found ' $BASEPBNAME ' header sources and tar archive;using what is there.'
else
	echo "untarring $PBTGZNAME ...";
	gunzip -dc ${PBTGZNAME} | tar xf -;
fi;

echo "building the szip library...";
cd ${BASEPBNAME}/szip;
./configure --with-pic --enable-shared=no \
    CC="${CC}" CFLAGS="${CFLAGS} -w"
$MAKE

echo "building the hdf5 library...";
cd ../;
## we add the '-w' flag to suppress all the warnings hdf5 prints
./configure --with-pic --enable-shared=no --enable-cxx \
    --with-szlib \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -std=c++11 -w" \
    CC="${CC}" CFLAGS="${CFLAGS} -w" \
    LDFLAGS="-L`pwd -P`/szip/src/.libs" \
    CPPFLAGS="-I`pwd -P`/szip/src/" 
$MAKE lib
cd ../../

#update variables in Makevars
HDF5_INCLUDE="${BASEPBNAME}/src"
HDF5_CXX_INCLUDE="${BASEPBNAME}/c++/src"
AC_SUBST(HDF5_INCLUDE)
AC_SUBST(HDF5_CXX_INCLUDE)
AC_MSG_NOTICE([   HDF5_INCLUDE=${HDF5_INCLUDE}])
AC_MSG_NOTICE([   HDF5_CXX_INCLUDE=${HDF5_CXX_INCLUDE}])

HDF5_LIB="${BASEPBNAME}/src/.libs/libhdf5.a"
HDF5_CXX_LIB="${BASEPBNAME}/c++/src/.libs/libhdf5_cpp.a"
SZIP_LIB="${BASEPBNAME}/szip/src/.libs/libsz.a"
AC_SUBST(HDF5_LIB)
AC_SUBST(HDF5_CXX_LIB)
AC_SUBST(SZIP_LIB)
AC_MSG_NOTICE([   HDF5_LIB=${HDF5_LIB}])
AC_MSG_NOTICE([   HDF5_CXX_LIB=${HDF5_CXX_LIB}])
AC_MSG_NOTICE([   SZIP_LIB=${SZIP_LIB}])
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
