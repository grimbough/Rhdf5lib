install_path <- file.path(getwd(), "inst")

cmake <- biocmake::find()

raw.options <- biocmake::configure(fortran.compiler=FALSE)

raw.options <- c(
    raw.options, 
    BUILD_TESTING="OFF",
    CMAKE_INSTALL_PREFIX=install_path,
    CMAKE_PREFIX_PATH=install_path,
    NULL
)

build_path <- "_build_hdf5"

source_path <- "vendor/hdf5"
h5.raw.options <- c(
    raw.options,
    HDF5_BUILD_CPP_LIB="ON",
    HDF5_BUILD_TOOLS="OFF",
    HDF5_BUILD_EXAMPLES="OFF",
    HDF5_ENABLE_Z_LIB_SUPPORT="ON",
    HDF5_ENABLE_SZIP_SUPPORT="ON",
    HDF5_ENABLE_ROS3_VFD="ON",
    NULL
)

if (.Platform$OS.type == "windows") {
    h5.raw.options[["CMAKE_C_FLAGS"]] <- paste(h5.raw.options[["CMAKE_C_FLAGS"]], "-DCURL_STATICLIB")
}

h5.options <- biocmake::formatArguments(h5.raw.options)
if (system2(cmake, c("-S", source_path, "-B", build_path, h5.options)) != 0) {
    stop("failed to configure the HDF5 library with CMake")
}

status <- system2(cmake, c("--build", build_path))
if (status != 0) {
    stop("failed to build the HDF5 library with CMake")
}

dir.create("inst", showWarnings=FALSE)
status <- system2(cmake, c("--install", build_path), stderr=FALSE)
if (status != 0) {
    stop("failed to install the HDF5 library with CMake")
}

# Remove this once h5testLock uses H5Pget_file_locking()
private_header_src <- c(
    file.path("vendor", "hdf5", "src", "H5private.h"),
    file.path("vendor", "hdf5", "src", "H5win32defs.h"),
    file.path("vendor", "hdf5", "src", "H5TSprivate.h")
)
dir.create(file.path(install_path, "include"), recursive=TRUE, showWarnings=FALSE)
file.copy(private_header_src, file.path(install_path, "include"), overwrite=TRUE)
