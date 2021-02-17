ver=1.10.
patch=7

cd /tmp/

curl https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${ver%.*}/hdf5-${ver}${patch}/src/CMake-hdf5-${ver}${patch}.tar.gz --output CMake-hdf5-${ver}${patch}.tar.gz
tar xzf CMake-hdf5-${ver}${patch}.tar.gz

## We need to add the followling lines to H5FDs3comms.h
#define CURL_STATICLIB

      execute_process(COMMAND "curl-config --static-libs" OUTPUT_VARIABLE CURL_LIBS)
	  string(STRIP ${CURL_LIBS} CURL_LIBS)
	  message(STATUS "MY_VAR=${CURL_LIBS}")
      #list (APPEND LINK_LIBS ${CURL_LIBRARIES} ${OPENSSL_LIBRARIES})
	  list (APPEND LINK_LIBS ${CURL_LIBS})


#curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/hdf5-cmake-size-type-checks.patch \
#  --output hdf5-cmake-size-type-checks.patch
curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/hdf5-default-import-suffix.patch \
  --output hdf5-default-import-suffix.patch
#curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/hdf5-fix-find-szip.patch \
#  --output hdf5-fix-find-szip.patch
#curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/hdf5-fix-install-docs.patch \
#  --output hdf5-fix-install-docs.patch
curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/hdf5-proper-library-names-mingw.patch \
  --output hdf5-proper-library-names-mingw.patch
#curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/utf8-windows-filenames.patch \
#  --output utf8-windows-filenames.patch

cd /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}

#patch -p1 -i ../../hdf5-cmake-size-type-checks.patch
patch -p1 -i ../../hdf5-default-import-suffix.patch
#patch -p1 -i ../../hdf5-fix-find-szip.patch
#patch -p1 -i ../../hdf5-fix-install-docs.patch
#patch -p1 -i ../../hdf5-proper-library-names-mingw.patch
#patch -p1 -i ../../utf8-windows-filenames.patch#

## we need libcurl for S3 VFD
pacman -Sy mingw-w64-{i686,x86_64}-curl
pacman -Sy mingw-w64-{i686,x86_64}-cmake
pacman -Sy mingw-w64-{i686,x86_64}-libtool
pacman -Sy mingw-w64-{i686,x86_64}-dlfcn


## MSYS, Rtools 3.9
export PATH=/c/Rtools/mingw_32/bin:/c/msys64/mingw32/bin:$PATH
export CPATH=/c/Rtools/mingw_32/i686-w64-mingw32/include:/c/Rtools/mingw_32/include:$CPATH
export LD_LIBRARY_PATH=/c/Rtools/mingw_32/i686-w64-mingw32/lib:/c/Rtools/mingw_32/lib:$LD_LiBRARY_PATH
cd /c/rtools40/tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}
mkdir build-rtools-${MINGW_CHOST}
cd build-rtools-${MINGW_CHOST}
rm -rf *

## leave testing and tools on - we can use them to check the build
/c/rtools40/mingw32/bin/cmake ../ -G "MSYS Makefiles" \
-DBUILD_SHARED_LIBS:BOOL=OFF \
-DHDF5_BUILD_HL_LIB:BOOL=ON \
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON \
-DBUILD_TESTING:BOOL=ON \
-DHDF5_BUILD_TOOLS:BOOL=ON \
-DHDF5_ALLOW_EXTERNAL_SUPPORT:STRING="TGZ" \
-DZLIB_TGZ_NAME:STRING="ZLib.tar.gz" \
-DSZIP_TGZ_NAME:STRING="SZip.tar.gz" \
-DTGZPATH:STRING="/c/rtools40/tmp/CMake-hdf5-${ver}${patch}" \
-DHDF5_ENABLE_ROS3_VFD:BOOL=ON \
-DCMAKE_C_STANDARD_LIBRARIES:STRING="-lws2_32 -lssh2 -lcrypt32 -lwldap32" \
-DCMAKE_CXX_STANDARD_LIBRARIES:STRING="-lws2_32 -lssh2 -lcrypt32 -lwldap32" \
-DCMAKE_BUILD_TYPE:STRING="Release"

## needed for linking
## edit in the ROS3 section of config/ConfigureChecks.cmake
# -lcurl -lssh2 -lgdi32 -lws2_32 -lssl -lcrypto -lcrypt32 -lwldap32 -lz

## MSYS, Rtools 3.9, 64bit
export PATH=/c/Rtools/mingw_64/bin:/c/msys64/mingw64/bin:$PATH
export CPATH=/c/Rtools/mingw_64/x86_64-w64-mingw32/include:/c/Rtools/mingw_64/include:$CPATH
export LD_LIBRARY_PATH=/c/Rtools/mingw_64/x86_64-w64-mingw32/lib:/c/Rtools/mingw_64/lib:$LD_LiBRARY_PATH
cd /c/rtools40/tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}
mkdir build-rtools-${MINGW_CHOST}
cd build-rtools-${MINGW_CHOST}
rm -rf *

/c/rtools40/mingw64/bin/cmake ../ -G "MSYS Makefiles" \
-DBUILD_SHARED_LIBS:BOOL=OFF \
-DHDF5_BUILD_HL_LIB:BOOL=ON \
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON \
-DBUILD_TESTING:BOOL=ON \
-DHDF5_BUILD_TOOLS:BOOL=ON \
-DHDF5_ALLOW_EXTERNAL_SUPPORT:STRING="TGZ" \
-DZLIB_TGZ_NAME:STRING="ZLib.tar.gz" \
-DSZIP_TGZ_NAME:STRING="SZip.tar.gz" \
-DTGZPATH:STRING="/c/rtools40/tmp/CMake-hdf5-${ver}${patch}" \
-DHDF5_ENABLE_ROS3_VFD:BOOL=ON \
-DCMAKE_C_STANDARD_LIBRARIES:STRING="-lws2_32 -lssh2 -lcrypt32 -lwldap32" \
-DCMAKE_CXX_STANDARD_LIBRARIES:STRING="-lws2_32 -lssh2 -lcrypt32 -lwldap32" \
-DCMAKE_BUILD_TYPE:STRING="Release"

cmake --build .




cd /tmp/CMake-hdf5-${ver}${patch}/
mkdir -p hdf5/c++ hdf5/hl

cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/c++/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/c++/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/hl/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/hl/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/hl/c++/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/hl/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/build-rtools-${MINGW_CHOST}/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/
tar cf - hdf5 | gzip -6 > hdf5_headers_${ver}${patch}.tar.gz
