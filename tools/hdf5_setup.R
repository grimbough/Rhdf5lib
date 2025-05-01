cmake <- biocmake::find()

options <- biocmake::formatArguments(biocmake::configure(fortran.compiler=FALSE))

options <- c(options, 
    "-DBUILD_SHARED_LIBS=OFF",
    "-DHDF5_BUILD_CPP_LIB=ON",
    "-DBUILD_TESTING=OFF",
    "-DHDF5_BUILD_TOOLS=OFF",
    "-DHDF5_BUILD_EXAMPLES=OFF",
    "-DHDF5_BUILD_UTILS=OFF",
    #"-DHDF5_ENABLE_PLUGIN_SUPPORT=ON",
    #"-DHDF5_ENABLE_HDFS=ON",
    #"-DHDF5_MINGW_STATIC_GCC_LIBS=ON",
    NULL
)

install_path <- file.path("inst", "hdf5")

if (!file.exists(install_path)) {
    tmp_dir <- "_temp"
    dir.create(tmp_dir, recursive=TRUE, showWarnings=FALSE)
    build_path <- file.path(tmp_dir, "build")

    if (!file.exists(build_path)) {
        source_path <- file.path(tmp_dir, "source")
        if (!file.exists(source_path)) {
            stopifnot(untar("sources.tar.gz", exdir=tmp_dir) == 0)
            first <- list.files(tmp_dir, pattern="^hdf5-")
            file.rename(file.path(tmp_dir, first), source_path)
        }

        options <- c(options, paste0("-DCMAKE_INSTALL_PREFIX=", install_path))
        system2(cmake, c("-S", source_path, "-B", build_path, options), stderr=FALSE)
    }

    if (.Platform$OS.type != "windows") {
        system2(cmake, c("--build", build_path))
    } else {
        system2(cmake, c("--build", build_path, "--config", "Release"))
    }

    dir.create("inst", showWarnings=FALSE)
    system2(cmake, c("--install", build_path), stderr=FALSE)
}
