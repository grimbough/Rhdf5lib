#' Compiler arguments for using Rhdf5lib
#' 
#' This function returns values for \code{PKG_CXX_LIBS} and
#' \code{PKG_CC_FLAGS} variables for use in Makevars files. 
#' 
#' @param opt A scalar character from the list of available options; 
#' default is \code{PKG_CXX_LIBS}.
#' @return \code{NULL}; prints the corresponding value to stdout.
#' @examples
#' pkgconfig("PKG_CXX_LIBS")
#' pkgconfig("PKG_C_LIBS")
#' @export
pkgconfig <- function(opt = c("PKG_CXX_LIBS", "PKG_C_LIBS")) {
    path <- system.file("lib", package="Rhdf5lib", mustWork=TRUE)
    if (nzchar(.Platform$r_arch)) {
        arch <- sprintf("/%s", .Platform$r_arch)
    } else {
        arch <- ""
    }
    patharch <- paste0(path, arch)
    
    result <- switch(match.arg(opt), 
                    # PKG_CPPFLAGS = {
                    #     sprintf('-I"%s"', system.file("include", package="Rhdf5lib"))
                    # }, 
                     PKG_C_LIBS = {
                         switch(Sys.info()['sysname'], 
                                Linux = {
                                    sprintf('%s/libhdf5.a',
                                            patharch)
                                }, Darwin = {
                                    sprintf('%s/libhdf5.a', 
                                            patharch)
                                }, Windows = {
                                    sprintf('-L%s -lhdf5 -lz -lws2_32 -ldl -lm -lpsapi', 
                                            patharch)
                                }
                         )
                     }, 
                     PKG_CXX_LIBS = {
                         switch(Sys.info()['sysname'], 
                                Linux = {
                                    sprintf('%s/libhdf5_cpp.a %s/libhdf5.a',
                                            patharch, patharch)
                                }, Darwin = {
                                    sprintf('%s/libhdf5_cpp.a %s/libhdf5.a', 
                                            patharch, patharch)
                                }, Windows = {
                                    sprintf('-L%s -lhdf5_cpp -lhdf5 -lz -lws2_32 -ldl -lm -lpsapi', 
                                            patharch)
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