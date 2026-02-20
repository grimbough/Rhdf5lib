install_path <- file.path(getwd(), "inst")

cmake <- biocmake::find()

raw.options <- biocmake::configure(fortran.compiler=FALSE)

raw.options <- c(
    raw.options, 
    BUILD_TESTING="OFF",
    BUILD_SHARED_LIBS="OFF",
    CMAKE_INSTALL_PREFIX=install_path,
    NULL
)

build_path <- "_build_libaec"

source_path <- "vendor/libaec"
aec.options <- biocmake::formatArguments(raw.options)
if (system2(cmake, c("-S", source_path, "-B", build_path, aec.options), stderr=FALSE) != 0) {
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
