LIB_DIR <- commandArgs(TRUE)[1]
INCLUDE_DIR <- commandArgs(TRUE)[2]

ARCH <- ifelse(R.version$arch == "x86_64", "x64", "i386")
CRT <- ifelse(R.version$crt == "ucrt", "-ucrt", "")
LIB_TYPE <- paste0(ARCH, CRT)

message("Copying libraries")
library_tarball <- file.path("winlib", LIB_TYPE, "libraries.tar.gz")
untar(tarfile = library_tarball, exdir = LIB_DIR)

message("Copying headers")
headers <- list.files("hdf5", full.names = TRUE, recursive = TRUE)
invisible(file.copy(from = headers,  to = INCLUDE_DIR))

message("Done")
