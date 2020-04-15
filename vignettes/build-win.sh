ver=1.10.
patch=6

cd /tmp/

curl https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${ver%.*}/hdf5-${ver}${patch}/src/CMake-hdf5-${ver}${patch}.tar.gz --output CMake-hdf5-${ver}${patch}.tar.gz
tar xzf CMake-hdf5-${ver}${patch}.tar.gz


curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/hdf5-cmake-size-type-checks.patch \
  --output hdf5-cmake-size-type-checks.patch
curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/hdf5-default-import-suffix.patch \
  --output hdf5-default-import-suffix.patch
curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/hdf5-fix-find-szip.patch \
  --output hdf5-fix-find-szip.patch
curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/hdf5-fix-install-docs.patch \
  --output hdf5-fix-install-docs.patch
curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/hdf5-proper-library-names-mingw.patch \
  -output hdf5-proper-library-names-mingw.patch
curl https://raw.githubusercontent.com/r-windows/rtools-packages/master/mingw-w64-hdf5/utf8-windows-filenames.patch \
  --output utf8-windows-filenames.patch

cd /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}

patch -p1 -i ../../hdf5-cmake-size-type-checks.patch
patch -p1 -i ../../hdf5-default-import-suffix.patch
patch -p1 -i ../../hdf5-fix-find-szip.patch
patch -p1 -i ../../hdf5-fix-install-docs.patch
patch -p1 -i ../../hdf5-proper-library-names-mingw.patch
patch -p1 -i ../../utf8-windows-filenames.patch

## we need libcurl for S3 VFD
pacman -Sy mingw-w64-{i686,x86_64}-curl
pacman -Sy mingw-w64-{i686,x86_64}-libtool
pacman -Sy mingw-w64-{i686,x86_64}-dlfcn

mkdir build-${MINGW_CHOST}
cd build-${MINGW_CHOST}
rm -rf *

${MINGW_PREFIX}/bin/cmake.exe ../ \
-G "MSYS Makefiles" \
-DBUILD_SHARED_LIBS:BOOL=ON \
-DHDF5_BUILD_HL_LIB:BOOL=ON \
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON \
-DBUILD_TESTING:BOOL=OFF \
-DHDF5_BUILD_TOOLS:BOOL=OFF \
-DHDF5_ALLOW_EXTERNAL_SUPPORT:STRING="TGZ" \
-DZLIB_TGZ_NAME:STRING="ZLib.tar.gz" \
-DSZIP_TGZ_NAME:STRING="SZip.tar.gz" \
-DTGZPATH:STRING="/tmp/CMake-hdf5-1.10.6" \
-DHDF5_ENABLE_ROS3_VFD:BOOL=ON \
-DCMAKE_C_STANDARD_LIBRARIES:STRING="-lws2_32" \
-DCMAKE_CXX_STANDARD_LIBRARIES:STRING="-lws2_32" \
-DCMAKE_BUILD_TYPE:STRING="Release"

cmake --build . 


## MSYS, Rtools 3.9
export PATH=/c/Rtools/mingw_32/bin:/c/msys64/mingw32/bin:$PATH
export CPATH=/c/Rtools/mingw_32/i686-w64-mingw32/include:/c/Rtools/mingw_32/include:$CPATH
export LD_LIBRARY_PATH=/c/Rtools/mingw_32/i686-w64-mingw32/lib:/c/Rtools/mingw_32/lib:$LD_LiBRARY_PATH
cd /c/rtools40/tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}
mkdir build-rtools39-${MINGW_CHOST}
cd build-rtools39-${MINGW_CHOST}
rm -rf *
/c/rtools40/mingw32/bin/cmake ../ -G "MSYS Makefiles" \
-DBUILD_SHARED_LIBS:BOOL=ON \
-DHDF5_BUILD_HL_LIB:BOOL=ON \
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON \
-DBUILD_TESTING:BOOL=OFF \
-DHDF5_BUILD_TOOLS:BOOL=OFF \
-DHDF5_ALLOW_EXTERNAL_SUPPORT:STRING="TGZ" \
-DZLIB_TGZ_NAME:STRING="ZLib.tar.gz" \
-DSZIP_TGZ_NAME:STRING="SZip.tar.gz" \
-DTGZPATH:STRING="/c/rtools40/tmp/CMake-hdf5-1.10.6" \
-DHDF5_ENABLE_ROS3_VFD:BOOL=ON \
-DCMAKE_C_STANDARD_LIBRARIES:STRING="-lws2_32" \
-DCMAKE_CXX_STANDARD_LIBRARIES:STRING="-lws2_32" \
-DCMAKE_BUILD_TYPE:STRING="Release"


## MSYS, Rtools 3.9, 64bit
export PATH=/c/Rtools/mingw_64/bin:/c/msys64/mingw64/bin:$PATH
export CPATH=/c/Rtools/mingw_64/x86_64-w64-mingw32/include:/c/Rtools/mingw_64/include:$CPATH
export LD_LIBRARY_PATH=/c/Rtools/mingw_64/x86_64-w64-mingw32/lib:/c/Rtools/mingw_64/lib:$LD_LiBRARY_PATH
cd /c/rtools40/tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}
mkdir build-rtools39-${MINGW_CHOST}
cd build-rtools39-${MINGW_CHOST}
rm -rf *

/c/rtools40/mingw64/bin/cmake ../ -G "MSYS Makefiles" \
-DBUILD_SHARED_LIBS:BOOL=ON \
-DHDF5_BUILD_HL_LIB:BOOL=ON \
-DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
-DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON \
-DBUILD_TESTING:BOOL=OFF \
-DHDF5_BUILD_TOOLS:BOOL=OFF \
-DHDF5_ALLOW_EXTERNAL_SUPPORT:STRING="TGZ" \
-DZLIB_TGZ_NAME:STRING="ZLib.tar.gz" \
-DSZIP_TGZ_NAME:STRING="SZip.tar.gz" \
-DTGZPATH:STRING="/c/rtools40/tmp/CMake-hdf5-${ver}${patch}" \
-DHDF5_ENABLE_ROS3_VFD:BOOL=ON \
-DCMAKE_C_STANDARD_LIBRARIES:STRING="-lws2_32" \
-DCMAKE_CXX_STANDARD_LIBRARIES:STRING="-lws2_32" \
-DCMAKE_BUILD_TYPE:STRING="Release"

/c/rtools40/mingw64/bin/cmake --build .




cd /tmp/CMake-hdf5-${ver}${patch}/
mkdir -p hdf5/c++ hdf5/hl

cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/c++/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/c++/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/hl/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/hl/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/hl/c++/src/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/hl/
cp /tmp/CMake-hdf5-${ver}${patch}/hdf5-${ver}${patch}/build-${MINGW_CHOST}/*.h /tmp/CMake-hdf5-${ver}${patch}/hdf5/
tar cf - hdf5 | gzip -6 > hdf5_headers_${ver}${patch}.tar.gz