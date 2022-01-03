# Build against static libraries from rwinlib
VERSION <- commandArgs(TRUE)[1]
DEST <- commandArgs(TRUE)[2]
INCLUDE_DEST <- commandArgs(TRUE)[3]

## We include the trailing slash (/) so as to exclude the "ucrt"
## versions of the x64 binaries, which don't link properly
ARCH <- ifelse(R.version$arch == "x86_64", "x64", "i386")
CRT <- ifelse(R.version$crt == "ucrt", "-ucrt/", "/")
LIB_TYPE <- paste0(ARCH, CRT)

message("Downloading dependencies")
if(getRversion() < "3.3.0") setInternet2()
download.file(sprintf("https://github.com/rwinlib/libcurl/archive/v%s.zip", VERSION), "lib.zip", quiet = TRUE, method = "auto")
file_path <- file.path(tempdir(), "libcurl")
dir.create(file_path, showWarnings = TRUE)
unzip("lib.zip", exdir = file_path)
arch_files <- grep(LIB_TYPE, x = list.files(file_path, recursive = TRUE, full.names = TRUE), value = TRUE)

message("Copying libraries")
print(arch_files)
invisible(file.copy(arch_files,  to = DEST))

file.remove("lib.zip")
