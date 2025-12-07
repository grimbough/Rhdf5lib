if (Sys.getenv("RHDF5LIB_USE_SYSTEM_LIBRARY", "0") == "1") {
    if (Sys.getenv("RHDF5LIB_FORCE_BUILD", "0") != "1") {
        quit(save="no", status=0)
    }
}

# If we already built it, we quit.
install_path <- file.path(getwd(), "inst")
if (file.exists(file.path(install_path, "lib", "libhdf5.a"))) {
    quit(save="no", status=0)
}

cmake <- biocmake::find()

raw.options <- biocmake::configure(fortran.compiler=FALSE)

raw.options <- c(
    raw.options, 
    BUILD_TESTING="OFF",
    CMAKE_INSTALL_PREFIX=install_path,
    NULL
)

build_path <- "_build_hdf5"

if (!file.exists(build_path)) {
    source_path <- "vendor/hdf5"
    h5.raw.options <- c(
        raw.options, 
        BUILD_SHARED_LIBS="OFF",
        HDF5_BUILD_CPP_LIB="ON",
        HDF5_BUILD_TOOLS="OFF",
        HDF5_BUILD_EXAMPLES="OFF",
        HDF5_ENABLE_SZIP_SUPPORT="ON",
        HDF5_USE_LIBAEC_STATIC="ON",
        CMAKE_PREFIX_PATH=install_path,
        #HDF5_ENABLE_ROS3_VFD="ON", # HDF5 2.0.0 now relies on the aws-c-s3 stack, which is painful to build. If you want it, link to a system library. 
        #HDF5_ENABLE_PLUGIN_SUPPORT="ON", # This should be handled by the rhdf5filters package, so we won't do it here.
        #HDF5_MINGW_STATIC_GCC_LIBS="ON", # ??? probably not necessary, R should be dynamically linking to them anyway if it's built by Rtools.
        NULL
    )

    if (.Platform$OS.type == "windows") {
        h5.raw.options[["CMAKE_C_FLAGS"]] <- paste(h5.raw.options[["CMAKE_C_FLAGS"]], "-DCURL_STATICLIB")
    }

    h5.options <- biocmake::formatArguments(h5.raw.options)
    if (system2(cmake, c("-S", source_path, "-B", build_path, h5.options)) != 0) {
        stop("failed to configure the HDF5 library with CMake")
    }
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

# Deleting useless directories to save some time.
unlink(file.path(install_path, "share"), recursive=TRUE)
unlink(file.path(install_path, "bin"), recursive=TRUE)
unlink(file.path(install_path, "cmake"), recursive=TRUE)
