#########################################################################
## Designed to be run with the MSYS2 terminals installed with Rtools40 ##
#########################################################################

ver=1.10.
patch=7

cd /tmp/

if ! [ -f CMake-hdf5-${ver}${patch}.tar.gz ]; then
  curl https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${ver%.*}/hdf5-${ver}${patch}/src/CMake-hdf5-${ver}${patch}.tar.gz --output CMake-hdf5-${ver}${patch}.tar.gz
fi

if [ "$#" -gt 0 ] && [ $1 == "clean" ]; then
  echo "Deleting existing directory"
  rm -r CMake-hdf5-${ver}${patch}
  echo "Extracting archive"
  tar xzf CMake-hdf5-${ver}${patch}.tar.gz
  
  ## We need to add the following lines to H5FDs3comms.h before curl.h is included.
  #define CURL_STATICLIB
  sed -i '/^#include <curl/i #define CURL_STATICLIB true' CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/src/H5FDs3comms.h
fi

## we need libcurl for S3 VFD
pacman -Sy --needed ${MINGW_PACKAGE_PREFIX}-curl \
                    ${MINGW_PACKAGE_PREFIX}-cmake \
                    ${MINGW_PACKAGE_PREFIX}-libtool \
                    ${MINGW_PACKAGE_PREFIX}-dlfcn


cd /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}
mkdir build-rtools-${MINGW_PACKAGE_PREFIX}
cd build-rtools-${MINGW_PACKAGE_PREFIX}
rm -rf *
  
cmake ../ -G "MSYS Makefiles" \
-DBUILD_SHARED_LIBS:BOOL=OFF \
-DHDF5_BUILD_HL_LIB:BOOL=ON \
-DHDF5_BUILD_CPP_LIB:BOOL=ON \
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON \
-DBUILD_TESTING:BOOL=ON \
-DHDF5_BUILD_TOOLS:BOOL=ON \
-DHDF5_ALLOW_EXTERNAL_SUPPORT:STRING="TGZ" \
-DZLIB_TGZ_NAME:STRING="ZLib.tar.gz" \
-DUSE_LIBAEC:BOOL=ON \
-DSZAEC_TGZ_NAME:STRING="LIBAEC.tar.gz" \
-DTGZPATH:STRING="/tmp/CMake-hdf5-${ver}${patch}" \
-DHDF5_ENABLE_ROS3_VFD:BOOL=ON \
-DCMAKE_BUILD_TYPE:STRING="MinSizeRel" \
-DCMAKE_C_STANDARD_LIBRARIES:STRING="-lssh2 -lws2_32 -lcrypt32 -lwldap32" 
  
cmake --build .
  
mkdir -p /tmp/winlibs/hdf5-${ver}${patch}/${MINGW_PACKAGE_PREFIX}
cp bin/lib*.a /tmp/winlibs/hdf5-${ver}${patch}/${MINGW_PACKAGE_PREFIX}

## We only need one copy of the headers
if [ ${MINGW_PACKAGE_PREFIX} == "mingw-w64-ucrt-x86_64" ]; then
  cd /tmp/CMake-hdf5-${ver}${patch}/
  mkdir -p hdf5/c++ hdf5/hl

  cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/
  cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/c++/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/c++/
  cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/hl/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/hl/
  cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/hl/c++/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/hl/
  cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/build-rtools-${MINGW_PACKAGE_PREFIX}/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/
  tar cf - hdf5 | gzip -6 > /tmp/hdf5_headers_${ver}${patch}.tar.gz
fi
