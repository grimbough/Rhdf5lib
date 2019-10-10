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
#' @examples
#' pkgconfig("PKG_C_LIBS")
#' pkgconfig("PKG_CXX_LIBS")
#' pkgconfig("PKG_C_HL_LIBS")
#' pkgconfig("PKG_CXX_HL_LIBS")
#' @export
#' @rawNamespace if(tools:::.OStype() == "windows") { importFrom(utils, shortPathName) }
pkgconfig <- function(opt = c("PKG_CXX_LIBS", "PKG_C_LIBS", "PKG_CXX_HL_LIBS", "PKG_C_HL_LIBS")) {
    
    path <- Sys.getenv(
        x = "RHDF5LIB_RPATH",
        unset = system.file("lib", package="Rhdf5lib", mustWork=TRUE)
    )
    
    if (nzchar(.Platform$r_arch)) {
        arch <- sprintf("/%s", .Platform$r_arch)
    } else {
        arch <- ""
    }
    patharch <- paste0(path, arch)
    #patharch <- gsub(x = patharch, pattern = " ", replacement = "\\ ", fixed = TRUE)

    result <- switch(match.arg(opt), 
                     PKG_C_LIBS = {
                         switch(Sys.info()['sysname'], 
                                Windows = {
                                    patharch <- gsub(x = utils::shortPathName(patharch),
                                                   pattern = "\\",
                                                   replacement = "/", 
                                                   fixed = TRUE)
                                    sprintf('-L%s -lhdf5 -lszip -lz -lpsapi', 
                                            patharch)
                                }, {
                                    sprintf('"%s/libhdf5.a" "%s/libsz.a" -lz', 
                                            patharch, patharch)
                                }
                         )
                     }, 
                     PKG_CXX_LIBS = {
                         switch(Sys.info()['sysname'], 
                                Windows = {
                                   ## for some reason double quotes aren't always sufficient
                                   ## so we use the 8+3 form of the path
                                   patharch <- gsub(x = utils::shortPathName(patharch),
                                                   pattern = "\\",
                                                   replacement = "/", 
                                                   fixed = TRUE)
                                    sprintf('-L%s -lhdf5_cpp -lhdf5 -lszip -lz -lpsapi', 
                                            patharch)
                                }, {
                                    sprintf('"%s/libhdf5_cpp.a" "%s/libhdf5.a" "%s/libsz.a" -lz',
                                            patharch, patharch, patharch)
                                }
                         )
                     },
                     PKG_C_HL_LIBS = {
                       switch(Sys.info()['sysname'], 
                              Windows = {
                                patharch <- gsub(x = shortPathName(patharch),
                                                 pattern = "\\",
                                                 replacement = "/", 
                                                 fixed = TRUE)
                                sprintf('-L%s -lhdf5_hl -lhdf5 -lszip -lz -lpsapi', 
                                        patharch)
                              }, {
                                sprintf('%s/libhdf5_hl.a %s/libhdf5.a %s/libsz.a -lz', 
                                        patharch, patharch, patharch)
                              }
                       )
                     }, 
                     PKG_CXX_HL_LIBS = {
                       switch(Sys.info()['sysname'], 
                              Windows = {
                                ## for some reason double quotes aren't always sufficient
                                ## so we use the 8+3 form of the path
                                patharch <- gsub(x = shortPathName(patharch),
                                                 pattern = "\\",
                                                 replacement = "/", 
                                                 fixed = TRUE)
                                sprintf('-L%s -lhdf5_hl_cpp -lhdf5_hl -lhdf5_cpp -lhdf5 -lszip -lz -lpsapi', 
                                        patharch)
                              }, {
                                sprintf('%s/libhdf5_hl_cpp.a %s/libhdf5_hl.a %s/libhdf5_cpp.a %s/libhdf5.a %s/libsz.a -lz',
                                        patharch, patharch, patharch, patharch, patharch)
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
  cReturn <- .Call("Rhdf5lib_hdf5_libversion", 
        PACKAGE = "Rhdf5lib")
  versionNum <- paste(cReturn, collapse = ".")
  return(versionNum)
}
