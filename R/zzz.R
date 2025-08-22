#' Compiler arguments for using Rhdf5lib
#' 
#' This function returns values for \code{PKG_LIBS} variables for use in 
#' Makevars files.
#' 
#' @param opt A scalar character from the list of available options; 
#' default is \code{PKG_CXX_LIBS}.  Valid options are \code{PKG_C_LIBS},
#' \code{PKG_CXX_LIBS}, \code{PKG_C_HL_LIBS}, \code{PKG_CXX_HL_LIBS} and
#' \code{PKG_CPP_FLAGS}, where \code{HL} indicates that you want to include the
#' HDF5 'high-level' API and \code{CXX} denotes including the C++ interface. 
#' @return \code{NULL}; prints the corresponding value to stdout.
#'
#' @details
#' If the \code{RHDF5LIB_USE_SYSTEM_LIBRARY} environment variable is set to 1,
#' \code{pkgconfig} will attempt to use the \code{pkg-config} command-line
#' utility to define the compiler/linker flags for the HDF5 system library.
#'
#' If the \code{RHDF5LIB_<opt>} environment variable is set (where \code{<opt>}
#' is any of the options for the \code{opt} argument), the value of the variable
#' will be returned directly. Administrators can use this to override the
#' behavior of \code{pkgconfig}.
#' 
#' @examples
#' pkgconfig("PKG_C_LIBS")
#' pkgconfig("PKG_CXX_LIBS")
#' pkgconfig("PKG_C_HL_LIBS")
#' pkgconfig("PKG_CXX_HL_LIBS")
#' @export
#' @rawNamespace if(tools:::.OStype() == "windows") { importFrom(utils, shortPathName) }
pkgconfig <- function(opt = c("PKG_CXX_LIBS", "PKG_C_LIBS", "PKG_CXX_HL_LIBS", "PKG_C_HL_LIBS", "PKG_CPP_FLAGS")) {
  opt <- match.arg(opt)

  attempt <- Sys.getenv(paste0("RHDF5LIB_", opt), NA)
  if(!is.na(attempt)) {
    cat(attempt)
    return(invisible(NULL))
  }

  if(.useSystemLibrary()) {
    if(opt == "PKG_CPP_FLAGS") {
      system2("pkg-config", c("hdf5", "--cflags-only-I"))
      return(invisible(NULL))
    } else {
      flags <- system2("pkg-config", c("hdf5", "--libs"), stdout=TRUE)
      if(opt == "PKG_CXX_LIBS") {
        flags <- paste(flags, "-lhdf5_cpp")
      } else if(opt == "PKG_C_HL_LIBS") {
        flags <- paste(flags, "-lhdf5_hl")
      } else if(opt == "PKG_CXX_HL_LIBS") {
        flags <- paste(flags, "-lhdf5_hl", "-lhdf5_cpp", "-lhdf5_hl_cpp")
      }
      cat(flags)
      return(invisible(NULL))
    }
  }

  raw_path <- Sys.getenv(
    x = "RHDF5LIB_RPATH",
    unset = system.file(package="Rhdf5lib", mustWork=TRUE)
  )

  if(opt == "PKG_CPP_FLAGS") {
    cat(paste0("-I", file.path(raw_path, "include")))
    return(invisible(NULL))
  }

  path <- file.path(raw_path, "lib")

  # Probably not necessary anymore - do we even build multiple architectures in a single package these days?
  patharch <- path
#  if(nzchar(.Platform$r_arch)) {
#    arch <- sprintf("/%s", .Platform$r_arch)
#  } else {
#    arch <- ""
#  }
#  patharch <- paste0(path, arch)

  sysname <- Sys.info()['sysname']
  if(sysname == "Windows") {
    
#    ## add "-ucrt" to the library directory if needed
#    ## this might be removed in the future - 2021-01-20
#    if(!is.null(R.version$crt) && R.version$crt == "ucrt" && R.version$arch == "x86_64") {
#      patharch <- paste0(patharch, "-ucrt")
#    }
    
    ## for some reason double quotes aren't always sufficient on Windows
    ## so we use the 8+3 form of the path and replace slashes
    patharch <- gsub(x = utils::shortPathName(patharch),
                     pattern = "\\",
                     replacement = "/", 
                     fixed = TRUE)
    
    winlibs <- "-lcurl -lssh2 -lssl -lcrypto -lwldap32 -lws2_32 -lcrypt32 -lszip -lz -lpsapi"
    if(!is.null(R.version$crt) && R.version$crt == "ucrt") {
      winlibs <- gsub(pattern = "-lszip", replacement = "-lsz -laec", x = winlibs, fixed = TRUE)
    }
  }
  
  result <- switch(opt,
                   PKG_C_LIBS = {
                     switch(sysname, 
                            Windows = {
                              sprintf('-L%s -lhdf5 %s', 
                                      patharch, winlibs)
                            }, {
                              sprintf('"%s/libhdf5.a"%s%s', 
                                      patharch, .getSzipLoc(patharch), .getDynamicLinks(path))
                            }
                     )
                   }, 
                   PKG_CXX_LIBS = {
                     switch(sysname, 
                            Windows = {
                              sprintf('-L%s -lhdf5_cpp -lhdf5 %s', 
                                      patharch, winlibs)
                            }, {
                              sprintf('"%s/libhdf5_cpp.a" "%s/libhdf5.a"%s%s',
                                      patharch, patharch, .getSzipLoc(patharch), .getDynamicLinks(path))
                            }
                     )
                   },
                   PKG_C_HL_LIBS = {
                     switch(sysname, 
                            Windows = {
                              sprintf('-L%s -lhdf5_hl -lhdf5 %s', 
                                      patharch, winlibs)
                            }, {
                              sprintf('"%s/libhdf5_hl.a" "%s/libhdf5.a"%s%s', 
                                      patharch, patharch, .getSzipLoc(patharch), .getDynamicLinks(path))
                            }
                     )
                   }, 
                   PKG_CXX_HL_LIBS = {
                     switch(sysname, 
                            Windows = {
                              sprintf('-L%s -lhdf5_hl_cpp -lhdf5_hl -lhdf5_cpp -lhdf5 %s', 
                                      patharch, winlibs)
                            }, {
                              sprintf('"%s/libhdf5_hl_cpp.a" "%s/libhdf5_hl.a" "%s/libhdf5_cpp.a" "%s/libhdf5.a"%s%s',
                                      patharch, patharch, patharch, patharch, .getSzipLoc(patharch), .getDynamicLinks(path))
                            }
                     )
                   }
  )
  
  cat(result)
}

.useSystemLibrary <- function() {
  Sys.getenv("RHDF5LIB_USE_SYSTEM_LIBRARY", "0") == "1"
}

#' Report the version of HDF5 distributed with this package
#' 
#' This function returns the version number of the HDF5 library that is 
#' distributed with this package.
#' 
#' @return Returns a \code{character} vector of length 1 containing the version
#' number.
#'
#' @details
#' If the \code{RHDF5LIB_USE_SYSTEM_LIBRARY} environment variable is set to 1,
#' the HDF5 library version is retrieved via \code{pkg-config}.
#'
#' If the \code{RHDF5LIB_LIBRARY_VERSION} environment variable is set,
#' the value of that environment variable is returned directly.
#'
#' @examples
#' getHdf5Version()
#' @export
getHdf5Version <- function() {
  attempt <- Sys.getenv("RHDF5LIB_LIBRARY_VERSION", NA)
  if(!is.na(attempt)) {
    return(attempt)
  }

  if(.useSystemLibrary()) {
    return(system2("pkg-config", c("hdf5", "--modversion"), stdout=TRUE))
  }

  settings_file <- system.file("lib", "libhdf5.settings", package="Rhdf5lib", mustWork=TRUE)
  libhdf5_settings <- readLines(settings_file)
  line <- grep("HDF5 Version:", x = libhdf5_settings)
  strsplit(libhdf5_settings[line], split = ": ")[[1]][2]
}

#' Return the link flags determined when HDF5 was configured
#' 
#' @keywords internal
.getDynamicLinks <- function(path) {
  sysname <- Sys.info()['sysname']
  if(sysname == "Windows") {
    links <- " -lz"
  } else {
    settings_file <- file.path(path, 'libhdf5.settings')
    libhdf5_settings <- readLines(settings_file)
    line <- grep("Extra libraries", x = libhdf5_settings)
    libstr <- strsplit(libhdf5_settings[line], split = ": ")[[1]][2]
    libs <- strsplit(libstr, split = ";")[[1]]

    # For some reason, HDF5 reports paths to the dynamic libraries rather than
    # just the names of the libraries, so we need to do some unpacking.
    base <- basename(libs)
    is.path <- grepl("^lib.*\\..*", base)
    libs[is.path] <- sub("lib([^\\.]+)\\..*", "\\1", base[is.path])

    links <- sprintf("-l%s", libs)
    links <- paste(c("", links), collapse=" ")
  }
  return(links)
}

#' If we compiled our own version of SZIP this returns the link path
#' Otherwise it returns an empty string.
#' 
#' @keywords internal
.getSzipLoc <- function(path) {
  sprintf(' "%s"', file.path(path, "libsz.a"))
}
