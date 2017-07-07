#' Rhdf5lib: A version of the HDF5 library built into an R package.
#' 
#' This package provides a compiled version of the HDF5 library bundled within
#' the R package structure.
#' It is primarily useful to developers of other R packages who want
#' to make use of the capabilities of the HDF5 library directly in the C or 
#' C++ code of their own packages, rather than using a higher level interface.
#'
#' @docType package
#' @name Rhdf5lib
#'
#' @useDynLib Rhdf5lib
#'
NULL
