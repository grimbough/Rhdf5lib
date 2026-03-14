install_path <- file.path(getwd(), "inst")

cmake <- biocmake::find()

raw_options <- biocmake::configure(fortran.compiler=FALSE)

raw_options <- c(
    raw_options, 
    BUILD_TESTING="OFF",
    BUILD_SHARED_LIBS="OFF",
    CMAKE_INSTALL_PREFIX=install_path,
    # Some systems (e.g., Fedora) will install to lib64 instead of lib, 
    # so we need to ensure that the libraries are always installed to inst/lib
    CMAKE_INSTALL_LIBDIR=file.path(install_path, "lib"),
    NULL
)

build_path <- "_build_libaec"

source_path <- "vendor/libaec"
aec_raw_options <- c(
    raw_options,
    LIBAEC_BUILD_TOOLS="OFF",
    NULL
)

aec_options <- biocmake::formatArguments(aec_raw_options)
if (system2(cmake, c("-S", source_path, "-B", build_path, aec_options), stderr=FALSE) != 0) {
    stop("failed to configure the libaec library with CMake")
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
