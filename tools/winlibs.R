# Build against static libraries from r-windows/bundles
DEST <- commandArgs(TRUE)[1]

## Determine the bundle suffix based on architecture and CRT
if (R.version$arch == "aarch64") {
  LIB_TYPE <- "clang-aarch64"
} else if (!is.null(R.version$crt) && R.version$crt == "ucrt") {
  LIB_TYPE <- "ucrt-x86_64"
} else {
  LIB_TYPE <- "clang-x86_64"
}

message("Downloading libcurl")

url <- paste0(
  "https://github.com/r-windows/bundles/releases/download/curl-8.14.1/",
  "curl-8.14.1-", LIB_TYPE, ".tar.xz"
)

tarball <- "curl.tar.xz"
download.file(url, destfile = tarball, quiet = TRUE, method = "auto")

## The bundle extracts as curl-8.14.1-<arch>/{include,lib}/...
## Strip that top-level directory so files land directly in DEST.
untar(tarfile = tarball, exdir = DEST, extras = "--strip-components=1")
