# Process this file with autoconf to produce a configure script.
# author: Mike Smith (mike.smith@embl.de)

AC_PREREQ([2.65])
AC_INIT([Rhdf5lib], [0.0.1], [mike.smith@embl.de])
AC_CONFIG_SRCDIR([src])

# Check the compiler configured with R
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  echo "could not determine R_HOME"
  exit 1
fi

CC=`"${R_HOME}/bin/R" CMD config CC`
CFLAGS=`"${R_HOME}/bin/R" CMD config CFLAGS`
MAKE=`${R_HOME}/bin/R CMD config MAKE`
CXX="${CXX}"
CXXFLAGS=`"${R_HOME}/bin/R" CMD config CXXFLAGS`
F77=`"${R_HOME}/bin/R" CMD config F77`
AC_LANG(C++)

# Checks for programs.
AC_PROG_CC
AC_PROG_CXX

#untar the lib
BASEPBNAME="hdf5"
PBTGZNAME=hdf5small_cxx.tar.gz
cd src
if test -d ./${BASEPBNAME}; then 
	echo 'found ' $BASEPBNAME ' header sources and tar archive;using what is there.'
else
	echo "untarring hdf5small.tgz ...";
	gunzip -dc ${PBTGZNAME} | tar xf -;
fi;

echo "building the bundled hdf5 library...";
cd ${BASEPBNAME};
## we add the '-w' flag to suppress all the warnings hdf5 prints
./configure  --with-pic --enable-shared=no --enable-cxx \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -w" CC="${CC}" CFLAGS="${CFLAGS} -w" F77="${F77}"
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
AC_SUBST(HDF5_LIB)
AC_SUBST(HDF5_CXX_LIB)
AC_MSG_NOTICE([   HDF5_LIB=${HDF5_LIB}])
AC_MSG_NOTICE([   HDF5_CXX_LIB=${HDF5_CXX_LIB}])
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
