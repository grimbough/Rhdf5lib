LIB_DIR <- commandArgs(TRUE)[1]
INCLUDE_DIR <- commandArgs(TRUE)[2]

## We include the trailing slash (/) so as to exclude the "ucrt"
## versions of the x64 binaries, which don't link properly
ARCH <- ifelse(R.version$arch == "x86_64", "x64", "i386")
CRT <- ifelse(R.version$crt == "ucrt", "-ucrt/", "/")
LIB_TYPE <- paste0(ARCH, CRT)

libraries <- list.files(file.path("winlib", LIB_TYPE), full.names = TRUE)
headers <- list.files("hdf5", full.names = TRUE, recursive = TRUE)

message("Copying libraries")
print(libraries)
invisible(file.copy(from = libraries,  to = LIB_DIR))

message("Copying headers")
invisible(file.copy(from = headers,  to = INCLUDE_DIR))

message("Done")
