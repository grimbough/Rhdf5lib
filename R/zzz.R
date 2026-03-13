#' Compiler arguments for using Rhdf5lib
#' 
#' This function returns values for \code{PKG_LIBS} variables for use in 
#' Makevars files.
#' 
#' @param opt A scalar character from the list of available options; 
#' default is \code{PKG_CXX_LIBS}.  Valid options are \code{PKG_C_LIBS},
#' \code{PKG_CXX_LIBS}, \code{PKG_C_HL_LIBS} and \code{PKG_CXX_HL_LIBS}, where
#' \code{HL} indicates that you want to include the HDF5 'high-level' API and
#' \code{CXX} denotes including the C++ interface. 
#' @return \code{NULL}; prints the corresponding value to stdout.
#' 
#' @examples
#' pkgconfig("PKG_C_LIBS")
#' pkgconfig("PKG_CXX_LIBS")
#' pkgconfig("PKG_C_HL_LIBS")
#' pkgconfig("PKG_CXX_HL_LIBS")
#' @export
#' @rawNamespace if(tools:::.OStype() == "windows") { importFrom(utils, shortPathName) }
pkgconfig <- function(opt = c("PKG_CXX_LIBS", "PKG_C_LIBS", "PKG_CXX_HL_LIBS", "PKG_C_HL_LIBS")) {
  opt <- match.arg(opt)

  path <- Sys.getenv(
    x = "RHDF5LIB_RPATH",
    unset = system.file("lib", package="Rhdf5lib", mustWork=TRUE)
  )

  sysname <- Sys.info()['sysname']
  if(sysname == "Windows") {
    ## for some reason double quotes aren't always sufficient on Windows
    ## so we use the 8+3 form of the path and replace slashes
    patharch <- gsub(x = utils::shortPathName(path),
                     pattern = "\\",
                     replacement = "/", 
                     fixed = TRUE)
    
    winlibs <- c("curl", "psl", "bcrypt", "zstd", "brotlidec", "brotlicommon", "idn2", "unistring", "nghttp2", "iconv", "ssh2", "gcrypt", "gpgme", "gpg-error", "secur32", "ssl", "crypto", "wldap32", "ws2_32", "crypt32", "sz", "aec", "z", "psapi", "secur32")
    winlibs <- paste(sprintf("-l%s", winlibs), collapse = " ")
  } else {
    patharch <- path
  }
  
  result <- switch(opt,
                   PKG_C_LIBS = {
                     switch(sysname, 
                            Windows = {
                              sprintf('-L%s -lhdf5 %s', 
                                      patharch, winlibs)
                            }, {
                              sprintf('"%s/libhdf5.a"%s%s', 
                                      patharch, .getSzipLoc(patharch), .getDynamicLinks(patharch))
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
                                      patharch, patharch, .getSzipLoc(patharch), .getDynamicLinks(patharch))
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
                                      patharch, patharch, .getSzipLoc(patharch), .getDynamicLinks(patharch))
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
                                      patharch, patharch, patharch, patharch, .getSzipLoc(patharch), .getDynamicLinks(patharch))
                            }
                     )
                   }
  )
  
  cat(result)
}

#' Report the version of HDF5 distributed with this package
#' 
#' This function returns the version number of the HDF5 library that is 
#' distributed with this package.
#' 
#' @return Returns a \code{character} vector of length 1 containing the version
#' number.
#' 
#' @examples
#' getHdf5Version()
#' @export
getHdf5Version <- function() {
  settings_file <- system.file("lib", "libhdf5.settings", package="Rhdf5lib", mustWork=TRUE)
  libhdf5_settings <- readLines(settings_file)
  line <- grep("HDF5 Version:", x = libhdf5_settings)
  strsplit(libhdf5_settings[line], split = ": ")[[1]][2]
}

#' Return the link flags determined when HDF5 was configured
#' 
#' @noRd
#' @keywords internal
.getDynamicLinks <- function(path) {
  settings_file <- file.path(path, "libhdf5.settings")
  libhdf5_settings <- readLines(settings_file)
  libstr <- grep("Extra libraries", x = libhdf5_settings, fixed = TRUE, value = TRUE) |> 
    gsub("\\s*Extra libraries: ", "", x = _)
  libs <- strsplit(libstr, split = ";", fixed = TRUE)[[1]]

  has.threads <- any(libs == "Threads::Threads")
  if (has.threads) {
    libs <- setdiff(libs, "Threads::Threads")
  }

  ## CMake records full paths (e.g. /usr/lib/libcurl.so) to libs, which we don't want
  libs <- .getLibShortName(libs)
  links <- ifelse(startsWith(libs, "/"), libs, paste0("-l", libs))

  if (has.threads) {
    # Clang doesn't support '-pthread' in the linker.
    compiler <- grep("C Compiler", libhdf5_settings) 
    if (length(compiler) && grep("gcc", libhdf5_settings[compiler])) {
      links <- c(links, "-pthread")
    }
  }

  links <- paste(c("", links), collapse=" ")

  return(links)
}

#' If we compiled our own version of SZIP this returns the link path
#' Otherwise it returns an empty string.
#' 
#' @noRd
#' @keywords internal
.getSzipLoc <- function(path) {
  status <- file.exists(file.path(path, "libsz.a"))
  if(isTRUE(status)) {
    ldflags <- sprintf(' -L"%s" -lsz', path)
  } else {
    ldflags <- ""
  }
  return(ldflags)
}

.getLibShortName <- function(libs) {
  base <- basename(libs)
  is.path <- grepl("^lib.*\\..*", base)
  libs[is.path] <- sub("lib([^\\.]+)\\..*", "\\1", base[is.path])

  return(libs)
}
