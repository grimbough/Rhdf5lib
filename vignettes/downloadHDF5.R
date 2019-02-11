library(stringr)

hdf5_source <- tempfile()
download.file(url = "https://s3.amazonaws.com/hdf-wordpress-1/wp-content/uploads/manual/HDF5/HDF5_1_10_4/hdf5-1.10.4.tar.bz2", 
              dest = hdf5_source)
untar(tarfile = hdf5_source, exdir = tempdir())
system2("mv", args = c(file.path(tempdir(), "hdf5-1.10.4"), file.path(tempdir(), "hdf5")))

## copy the SZIP source 
untar("~/Projects/Rhdf5lib/src/hdf5small_cxx_1.10.3.tar.gz", 
      files = "hdf5/szip", 
      exdir = tempdir())

setwd(file.path(tempdir(), "hdf5"))

unlink(x = c("examples", "fortran", "java", "release_docs", "test", "testpar", "tools", 
             "c++/examples", "c++/test", 
             "hl/fortran", "hl/examples", "hl/tools", "hl/test"),
       recursive = TRUE)

configure_ac <- xfun::read_utf8("configure.ac")

## modify list of build files
start <- which(str_detect(configure_ac, pattern = "AC_CONFIG_FILES"))
end <- which(str_detect(configure_ac[start:(length(configure_ac))], pattern = "\\)$"))[1] + start - 1
config_files <- configure_ac[start:end]
rm_idx <- which(str_detect(config_files, pattern = "test/|testpar/|tools/|examples/|fortran/|java/"))
config_files <- config_files[-rm_idx]
config_files[length(config_files)] <- paste0(tail(config_files, 1), "])")
configure_ac[start] <- paste(config_files, collapse = "\n")
configure_ac <- configure_ac[-((start+1):(end))]

## remove reference to h5cc
h5cc <- str_which(configure_ac, pattern = "chmod 755 tools/src/misc/h5cc")
configure_ac <- configure_ac[-((h5cc):(h5cc+4))]

## fortran headers
fortran_inc <- str_which(configure_ac, pattern = "AC_CONFIG_HEADERS\\(\\[fortran/src/H5config_f\\.inc")
configure_ac[fortran_inc:(fortran_inc+1)] <- paste("##", configure_ac[fortran_inc:(fortran_inc+1)])

## write 
xfun::write_utf8(configure_ac, con = "configure.ac")

## C++ makefile
make_cplusplus <- xfun::read_utf8('c++/Makefile.am')
idx <- str_which(make_cplusplus, "BUILD_CXX_CONDITIONAL")
make_cplusplus[idx] <- "if BUILD_CXX_CONDITIONAL\n\tSUBDIRS=src\nendif\nDIST_SUBDIRS = src"
make_cplusplus <- make_cplusplus[-((idx+1):(length(make_cplusplus)-1))] 
xfun::write_utf8(make_cplusplus, con = "c++/Makefile.am")

## HL makefile
make_hl <- xfun::read_utf8('hl/Makefile.am')
idx <- str_which(make_hl, "BUILD_HDF5_HL_CONDITIONAL")
make_hl[idx] <- "if BUILD_HDF5_HL_CONDITIONAL\n\tSUBDIRS=src $(CXX_DIR)\nendif\nDIST_SUBDIRS = src c++"
make_hl <- make_hl[-((idx+1):(length(make_hl)-1))] 
xfun::write_utf8(make_hl, con = "hl/Makefile.am")

## Primary makefile
make <- xfun::read_utf8('Makefile.am')
idx <- str_which(make, "SUBDIRS = src test")[1]
make[idx] <- "SUBDIRS = src . $(CXX_DIR) $(HDF5_HL_DIR)"
make[idx+1] <- "DIST_SUBDIRS = src . c++ hl"
make[idx+2]  <- ""
idx <- str_which(make, "# Make all, tests, and \\(un\\)install")
make[(idx+1):(idx+6)] <- paste0("##", make[(idx+1):(idx+6)])
xfun::write_utf8(make, con = "Makefile.am")

system2(command = "autoconf")
system2("aclocal")
system2("automake")
unlink("autom4te.cache", recursive = TRUE)

setwd(tempdir())
tar("hdf5small_cxx_hl_1.10.4.tar.gz", file = "hdf5", compression = "gzip", compression_level = 7)



