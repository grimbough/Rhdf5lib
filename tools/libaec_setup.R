cmake <- biocmake::find()

options <- biocmake::formatArguments(biocmake::configure(fortran.compiler=FALSE))
aec.tgz <- "libaec-source.tar.gz"

options <- c(options, 
    "-DBUILD_TESTING=OFF",
    NULL
)

tmp_dir <- "_temp_libaec"
install_path <- file.path(tmp_dir, "install")

if (!file.exists(install_path)) {
    dir.create(tmp_dir, recursive=TRUE, showWarnings=FALSE)
    build_path <- file.path(tmp_dir, "build")

    if (!file.exists(build_path)) {
        source_path <- file.path(tmp_dir, "source")
        if (!file.exists(source_path)) {
            stopifnot(untar("libaec-source.tar.gz", exdir=tmp_dir) == 0)
            first <- list.files(tmp_dir, pattern="^libaec-")
            file.rename(file.path(tmp_dir, first), source_path)
        }

        options <- c(options, paste0("-DCMAKE_INSTALL_PREFIX=", install_path))
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
