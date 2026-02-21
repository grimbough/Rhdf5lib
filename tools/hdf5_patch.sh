#!/bin/bash
# Patch upstream HDF5 vendor sources to link system libraries by short name
# (-lcurl, -lssl, -lcrypto, -lz) instead of full paths.

set -euo pipefail

VENDOR_DIR="vendor/hdf5"

# ConfigureChecks.cmake: use -lcurl -lssl -lcrypto instead of full paths
sed -i 's/list (APPEND LINK_LIBS ${CURL_LIBRARIES} ${OPENSSL_LIBRARIES})/list (APPEND LINK_LIBS curl ssl crypto ssh2)/' \
  "${VENDOR_DIR}/config/cmake/ConfigureChecks.cmake"

# CMakeFilters.cmake: use -lz instead of full paths for zlib
sed -i 's/set (LINK_COMP_LIBS ${LINK_COMP_LIBS} ${ZLIB_LIBRARIES})/set (LINK_COMP_LIBS ${LINK_COMP_LIBS} z)/' \
  "${VENDOR_DIR}/CMakeFilters.cmake"
