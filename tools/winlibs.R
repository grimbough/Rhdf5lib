# Build against static libraries from rwinlib
VERSION <- commandArgs(TRUE)[1]
ARCH <- commandArgs(TRUE)[2]
DEST <- commandArgs(TRUE)[3]

message("Copying Winlibs")
  if(getRversion() < "3.3.0") setInternet2()
  download.file(sprintf("https://github.com/rwinlib/libcurl/archive/v%s.zip", VERSION), "lib.zip", quiet = TRUE)
  file_path <- file.path(tempdir(), "libcurl")
  dir.create(file_path, showWarnings = FALSE)
  unzip("lib.zip", exdir = file_path)
  arch_files <- grep(ARCH, x = list.files(file_path, recursive = TRUE, full.names = TRUE), value = TRUE)
  file.copy(arch_files, to = DEST)
  unlink("lib.zip")
