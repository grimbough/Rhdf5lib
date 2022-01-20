# Build against static libraries from rwinlib
DEST <- commandArgs(TRUE)[1]

## We include the trailing slash (/) so as to exclude the "ucrt"
## versions of the x64 binaries, which don't link properly
ARCH <- ifelse(R.version$arch == "x86_64", "x64/", "i386/")
CRT <- ifelse(!is.null(R.version$crt) && R.version$crt == "ucrt", "-ucrt/", "/")
LIB_TYPE <- gsub("/", CRT, ARCH)


## if we're using the UCRT version of libraries are distributed with the package
## otherwise use the rwinlib versions
## we use our own version because rhdf5 S3 operations crash using the rwinlib curl-7.64.1
if(!is.null(R.version$crt) && R.version$crt == "ucrt") {
  message("Copying libcurl etc")
  
  library_tarball <- file.path("winlib", LIB_TYPE, "curl-7.64.1_openssl-1.1.1m_ssh2-1.10.0.tar.gz")
  untar(tarfile = library_tarball, exdir = DEST)
  
} else {
  message("Downloading libcurl etc")

  url <- "https://github.com/rwinlib/libcurl/archive/v7.64.1.zip"

  download.file(url, 
                destfile = "lib.zip", 
                quiet = TRUE, method = "auto")
  file_path <- file.path(tempdir(), "libcurl")
  dir.create(file_path, showWarnings = TRUE)
  unzip("lib.zip", exdir = file_path)
  arch_files <- grep(LIB_TYPE, 
                     x = list.files(file_path, recursive = TRUE, full.names = TRUE), 
                     value = TRUE)
  
  message("Copying libraries")
  print(arch_files)
  invisible(file.copy(arch_files,  to = DEST))
  
  invisible(file.remove("lib.zip"))
}