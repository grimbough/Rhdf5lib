cmake <- biocmake::find()

options <- biocmake::formatArguments(biocmake::configure(fortran.compiler=FALSE))

install_path <- file.path(getwd(), "inst")
options <- c(options, 
    "-DBUILD_TESTING=OFF",
    paste0("-DCMAKE_INSTALL_PREFIX=", install_path),
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

        if (system2(cmake, c("-S", source_path, "-B", build_path, options), stderr=FALSE) != 0) {
            stop("failed to configure the libaec library with CMake")
        }
    }

    if (.Platform$OS.type != "windows") {
        status <- system2(cmake, c("--build", build_path))
    } else {
        status <- system2(cmake, c("--build", build_path, "--config", "Release"))
    }
    if (status != 0) {
        stop("failed to build the libaec library with CMake")
    }

    dir.create("inst", showWarnings=FALSE)
    status <- system2(cmake, c("--install", build_path), stderr=FALSE)
    if (status != 0) {
        stop("failed to install the libaec library with CMake")
    }
}

#####################
### Building HDF5 ###
#####################

h5.options <- c(options, 
    "-DBUILD_SHARED_LIBS=OFF",
    "-DHDF5_BUILD_CPP_LIB=ON",
    "-DHDF5_BUILD_TOOLS=OFF",
    "-DHDF5_BUILD_EXAMPLES=OFF",
    "-DHDF5_BUILD_UTILS=OFF",
    paste0("-DCMAKE_PREFIX_PATH=", install_path),
    "-DHDF5_USE_LIBAEC_STATIC=ON",
    "-DHDF5_ENABLE_ROS3_VFD=ON",
    #"-DHDF5_ENABLE_PLUGIN_SUPPORT=ON", # This should be handled by the rhdf5filters package, so we won't do it here.
    #"-DHDF5_MINGW_STATIC_GCC_LIBS=ON", # ??? probably not necessary, R should be dynamically linking to them anyway if it's built by Rtools.
    NULL
)

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

        if (system2(cmake, c("-S", source_path, "-B", build_path, h5.options)) != 0) {
            stop("failed to configure the HDF5 library with CMake")
        }
    }

    if (.Platform$OS.type != "windows") {
        status <- system2(cmake, c("--build", build_path))
    } else {
        status <- system2(cmake, c("--build", build_path, "--config", "Release"))
    }
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
