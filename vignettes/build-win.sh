ver=1.10.
patch=7

#BUILD_i386=true
#BUILD_x64=true
BUILD_x64_ucrt=true

cd /tmp/

if ! [ -f CMake-hdf5-${ver}${patch}.tar.gz ]; then
  curl https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${ver%.*}/hdf5-${ver}${patch}/src/CMake-hdf5-${ver}${patch}.tar.gz --output CMake-hdf5-${ver}${patch}.tar.gz
fi

if [ -d CMake-hdf5-${ver}${patch} ]; then
  echo "Deleting existing directory"
  rm -r CMake-hdf5-${ver}${patch}
fi

tar xzf CMake-hdf5-${ver}${patch}.tar.gz

## We need to add the followling lines to H5FDs3comms.h before curl.h is included.
#define CURL_STATICLIB
sed -i '/^#include <curl/i #define CURL_STATICLIB true' CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/src/H5FDs3comms.h

## we need libcurl for S3 VFD
pacman -Sy --needed mingw-w64-{i686,x86_64,ucrt-x86_64}-curl
pacman -Sy --needed mingw-w64-{i686,x86_64,ucrt-x86_64}-cmake
pacman -Sy --needed mingw-w64-{i686,x86_64,ucrt-x86_64}-libtool
pacman -Sy --needed mingw-w64-{i686,x86_64,ucrt-x86_64}-dlfcn

if [ ! -z ${BUILD_i386+x} ]; then
  mkdir -p /tmp/winlibs/hdf5-${ver}${patch}/i386
  
  export PATH=/c/rtools40/mingw32/bin:/usr/bin
  export CPATH=/c/rtools40/mingw32/i686-w64-mingw32/include:/c/rtools40/mingw32/include
  export LD_LIBRARY_PATH=/c/rtools40/mingw32/i686-w64-mingw32/lib:/c/rtools40/mingw32/lib
  cd /c/rtools40/tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}
  mkdir build-rtools-i686
  cd build-rtools-i686
  rm -rf *
  
  ## leave testing and tools on - we can use them to check the build
  /c/rtools40/mingw32/bin/cmake ../ -G "MSYS Makefiles" \
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
  -DTGZPATH:STRING="/c/rtools40/tmp/CMake-hdf5-${ver}${patch}" \
  -DHDF5_ENABLE_ROS3_VFD:BOOL=ON \
  -DCMAKE_C_STANDARD_LIBRARIES:STRING="-lws2_32 -lssh2 -lcrypt32 -lwldap32" \
  -DCMAKE_CXX_STANDARD_LIBRARIES:STRING="-lws2_32 -lssh2 -lcrypt32 -lwldap32" \
  -DCMAKE_C_FLAGS:STRING="-O2 -Wall  -std=gnu99 -mfpmath=sse -msse2 -mstackrealign" \
  -DCMAKE_BUILD_TYPE:STRING="Release"
  
  cmake --build .
  
  cp bin/lib*.a /tmp/winlibs/hdf5-${ver}${patch}/i386
  
fi

if [ ! -z ${BUILD_x64+x} ]; then

  mkdir -p /tmp/winlibs/hdf5-${ver}${patch}/x64

  export PATH=/c/rtools40/mingw64/bin:/usr/bin
  export CPATH=/c/rtools40/mingw64/x86_64-w64-mingw32/include:/c/rtools40/mingw64/include
  export LD_LIBRARY_PATH=/c/rtools40/mingw64/x86_64-w64-mingw32/lib:/c/rtools40/mingw64/lib
  cd /c/rtools40/tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}
  mkdir build-rtools-x64
  cd build-rtools-x64
  rm -rf *
  
  /c/rtools40/mingw64/bin/cmake ../ -G "MSYS Makefiles" \
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
  -DTGZPATH:STRING="/c/rtools40/tmp/CMake-hdf5-${ver}${patch}" \
  -DHDF5_ENABLE_ROS3_VFD:BOOL=ON \
  -DCMAKE_C_STANDARD_LIBRARIES:STRING="-lws2_32 -lssh2 -lcrypt32 -lwldap32" \
  -DCMAKE_CXX_STANDARD_LIBRARIES:STRING="-lws2_32 -lssh2 -lcrypt32 -lwldap32" \
  -DCMAKE_BUILD_TYPE:STRING="Release"
  
  cmake --build .
  
  cp bin/lib*.a /tmp/winlibs/hdf5-${ver}${patch}/x64
fi

if [ ! -z ${BUILD_x64_ucrt+x} ]; then

  mkdir -p /tmp/winlibs/hdf5-${ver}${patch}/x64-ucrt
  
  export PATH=/c/rtools40/ucrt64/bin:/usr/bin
  export CPATH=/c/rtools40/ucrt64/x86_64-w64-mingw32/include:/c/rtools40/ucrt64/include
  export LD_LIBRARY_PATH=/c/rtools40/ucrt64/x86_64-w64-mingw32/lib:/c/rtools40/ucrt64/lib
  cd /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}
  mkdir build-rtools-x64-ucrt
  cd build-rtools-x64-ucrt
  rm -rf *
  
  /ucrt64/bin/cmake ../ -G "MSYS Makefiles" \
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
  -DCMAKE_C_STANDARD_LIBRARIES:STRING="-lws2_32 -lssh2 -lcrypt32 -lwldap32" \
  -DCMAKE_CXX_STANDARD_LIBRARIES:STRING="-lws2_32 -lssh2 -lcrypt32 -lwldap32" \
  -DCMAKE_BUILD_TYPE:STRING="Release"
  
  cmake --build .
  
  cp bin/lib*.a /tmp/winlibs/hdf5-${ver}${patch}/x64-ucrt
fi

cd /tmp/CMake-hdf5-${ver}${patch}/
mkdir -p hdf5/c++ hdf5/hl

cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/c++/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/c++/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/hl/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/hl/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/hl/c++/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/hl/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/build-rtools-x64-ucrt/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/
tar cf - hdf5 | gzip -6 > /tmp/hdf5_headers_${ver}${patch}.tar.gz
