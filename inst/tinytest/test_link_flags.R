library(mockery)
library(Rhdf5lib)

## testing windows behaviour on a non-windows OS
mockOS <- mock(setNames("Windows", "sysname"), 
               setNames("Linux", "sysname"),
               cycle = TRUE)
stub(pkgconfig, what = "Sys.info", how = mockOS)
stub(pkgconfig, what = "utils::shortPathName", how = "c:/foobar/")

##  Windows
expect_stdout(
  pkgconfig(opt = "PKG_C_LIBS"),
  pattern = "foobar/ -lhdf5"
)
##  Non-Windows
expect_stdout(
  pkgconfig(opt = "PKG_C_LIBS"),
  pattern = "libhdf5.a"
)

##  Windows
expect_stdout(
  pkgconfig(opt = "PKG_CXX_LIBS"),
  pattern = "foobar/ -lhdf5_cpp -lhdf5"
)
##  Non-Windows
expect_stdout(
  pkgconfig(opt = "PKG_CXX_LIBS"),
  pattern = "libhdf5_cpp.a"
)

##  Windows
expect_stdout(
  pkgconfig(opt = "PKG_C_HL_LIBS"),
  pattern = "foobar/ -lhdf5_hl -lhdf5"
)
##  Non-Windows
expect_stdout(
  pkgconfig(opt = "PKG_C_HL_LIBS"),
  pattern = "libhdf5_hl.a"
)

##  Windows
expect_stdout(
  pkgconfig(opt = "PKG_CXX_HL_LIBS"),
  pattern = "foobar/ -lhdf5_hl_cpp -lhdf5_hl -lhdf5_cpp -lhdf5"
)
##  Non-Windows
expect_stdout(
  pkgconfig(opt = "PKG_CXX_HL_LIBS"),
  pattern = "libhdf5_hl_cpp.a"
)
