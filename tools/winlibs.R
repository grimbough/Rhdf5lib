# Build against static libraries from rwinlib
VERSION <- commandArgs(TRUE)[1]
DEST <- commandArgs(TRUE)[2]

## We include the trailing slash (/) so as to exclude the "ucrt"
## versions of the x64 binaries, which don't link properly
ARCH <- ifelse(R.version$arch == "x86_64", "x64/", "i386/")

message("Copying Winlibs")
if(getRversion() < "3.3.0") setInternet2()
download.file(sprintf("https://github.com/rwinlib/libcurl/archive/v%s.zip", VERSION), "lib.zip", quiet = TRUE)
file_path <- file.path(tempdir(), "libcurl")
message(file_path)
dir.create(file_path, showWarnings = TRUE)
unzip("lib.zip", exdir = file_path)
list.files(file_path, recursive = TRUE, full.names = TRUE)
arch_files <- grep(ARCH, x = list.files(file_path, recursive = TRUE, full.names = TRUE), value = TRUE)

message(arch_files)
message("ARCH: ", ARCH)

lapply(arch_files, file.copy, to = DEST)
unlink("lib.zip")
