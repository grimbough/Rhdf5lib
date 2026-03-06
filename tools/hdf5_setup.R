install_path <- file.path(getwd(), "inst")

cmake <- biocmake::find()

raw.options <- biocmake::configure(fortran.compiler=FALSE)

raw.options <- c(
    raw.options, 
    BUILD_TESTING="OFF",
    CMAKE_INSTALL_PREFIX=install_path,
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
    CMAKE_PREFIX_PATH=install_path,
    #HDF5_ENABLE_PLUGIN_SUPPORT="ON", # This should be handled by the rhdf5filters package, so we won't do it here.
    #HDF5_MINGW_STATIC_GCC_LIBS="ON", # ??? probably not necessary, R should be dynamically linking to them anyway if it's built by Rtools.
    NULL
)

if (.Platform$OS.type == "windows") {
    # Use pkg-config from the Rtools static toolchain to let CMake's FindCURL
    # resolve curl and all its transitive static dependencies automatically
    # (including nghttp2, which is new in Rtools45).
    # Derive the sysroot from the standard RTOOLS45_HOME environment variable,
    # which is always set by the Rtools installer, e.g.:
    #   C:/rtools45  (ucrt64/Intel)
    #   C:/rtools45-aarch64  (ARM)
    rtools_home <- Sys.getenv("RTOOLS45_HOME")
    if (!nzchar(rtools_home)) {
        stop("RTOOLS45_HOME is not set; please install Rtools45")
    }
    arch <- if (.Machine$sizeof.pointer == 4L) "i686" else {
        if (grepl("aarch64", R.version$arch)) "aarch64" else "x86_64"
    }
    rtools_sysroot <- file.path(
        rtools_home,
        paste0(arch, "-w64-mingw32.static.posix")
    )
    pkgconfig_path <- file.path(rtools_sysroot, "lib", "pkgconfig")
    pkgconfig_path <- gsub("\\", "/", pkgconfig_path, fixed = TRUE)
    old_path <- Sys.getenv("PKG_CONFIG_PATH")
    new_path <- if (nzchar(old_path)) paste(pkgconfig_path, old_path, sep = ";") else pkgconfig_path
    Sys.setenv(PKG_CONFIG_PATH = new_path)

    # Force CMake to use the FindCURL module (which honours PKG_CONFIG_PATH
    # and uses --static) rather than curl's own cmake config files.
    h5.raw.options[["CURL_NO_CURL_CMAKE"]] <- "TRUE"

    # When linking a shared library against static libcurl on Windows, all
    # transitive dependencies must appear explicitly on the link line.
    # In Rtools45, libcurl depends on nghttp2 (new in Rtools45), openssl
    # (which itself needs ws2_32 and crypt32), and several other system libs.
    # Ask pkg-config for the full static link flags and pass them as extra
    # shared linker flags so that the hdf5 DLL links cleanly.
    pkgconf_exe <- file.path(rtools_sysroot, "bin", "pkgconf.exe")
    if (file.exists(pkgconf_exe)) {
        curl_libs <- tryCatch(
            system2(pkgconf_exe,
                    c("--static", "--libs", "libcurl"),
                    stdout = TRUE, stderr = FALSE,
                    env = paste0("PKG_CONFIG_PATH=", new_path)),
            error = function(e) character(0)
        )
        if (length(curl_libs) > 0L && nzchar(curl_libs[1L])) {
            h5.raw.options[["CMAKE_SHARED_LINKER_FLAGS"]] <- curl_libs[1L]
        }
    }
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
