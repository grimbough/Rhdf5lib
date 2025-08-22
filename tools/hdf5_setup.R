if (Sys.getenv("RHDF5LIB_USE_SYSTEM_LIBRARY", "0") == "1") {
    quit(save="no")
}

cmake <- biocmake::find()

raw.options <- biocmake::configure(fortran.compiler=FALSE)

install_path <- file.path(getwd(), "inst")
raw.options <- c(
    raw.options, 
    BUILD_TESTING="OFF",
    CMAKE_INSTALL_PREFIX=install_path,
    NULL
)

#######################
### Building libaec ###
#######################

if (!file.exists(file.path(install_path, "lib", "libaec.a"))) {
    tmp_dir <- "_temp_libaec"
    dir.create(tmp_dir, recursive=TRUE, showWarnings=FALSE)
    build_path <- file.path(tmp_dir, "build")

    if (!file.exists(build_path)) {
        source_path <- file.path(tmp_dir, "source")
        if (!file.exists(source_path)) {
            stopifnot(untar("libaec-source.tar.gz", exdir=tmp_dir) == 0)
            first <- list.files(tmp_dir, pattern="^libaec-")
            file.rename(file.path(tmp_dir, first), source_path)
        }

        aec.options <- biocmake::formatArguments(raw.options)
        if (system2(cmake, c("-S", source_path, "-B", build_path, aec.options), stderr=FALSE) != 0) {
            stop("failed to configure the libaec library with CMake")
        }
    }

    status <- system2(cmake, c("--build", build_path))
    if (status != 0) {
        stop("failed to build the libaec library with CMake")
    }

    dir.create("inst", showWarnings=FALSE)
    status <- system2(cmake, c("--install", build_path), stderr=FALSE)
    if (status != 0) {
        stop("failed to install the libaec library with CMake")
    }
}

# Deleting the shared libraries because we don't need those.
lib.path <- file.path(install_path, "lib")
all.libs <- list.files(lib.path)
unlink(file.path(lib.path, all.libs[grep("lib(aec|sz)\\.(so|dll).*", all.libs)]))

#####################
### Building HDF5 ###
#####################

if (!file.exists(file.path(install_path, "lib", "libhdf5.a"))) {
    tmp_dir <- "_temp_hdf5"
    dir.create(tmp_dir, recursive=TRUE, showWarnings=FALSE)
    build_path <- file.path(tmp_dir, "build")

    if (!file.exists(build_path)) {
        source_path <- file.path(tmp_dir, "source")
        if (!file.exists(source_path)) {
            stopifnot(untar("hdf5-source.tar.gz", exdir=tmp_dir) == 0)
            first <- list.files(tmp_dir, pattern="^hdf5-")
            file.rename(file.path(tmp_dir, first), source_path)
        }

        h5.raw.options <- c(
            raw.options, 
            BUILD_SHARED_LIBS="OFF",
            HDF5_BUILD_CPP_LIB="ON",
            HDF5_BUILD_TOOLS="OFF",
            HDF5_BUILD_EXAMPLES="OFF",
            HDF5_BUILD_UTILS="OFF",
            CMAKE_PREFIX_PATH=install_path,
            HDF5_USE_LIBAEC_STATIC="ON",
            HDF5_ENABLE_ROS3_VFD="ON",
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
}

############################################
### Deleting all the useless directories ###
############################################

unlink(file.path(install_path, "share"), recursive=TRUE)
unlink(file.path(install_path, "bin"), recursive=TRUE)
unlink(file.path(install_path, "cmake"), recursive=TRUE)
