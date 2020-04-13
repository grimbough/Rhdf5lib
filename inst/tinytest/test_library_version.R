
expect_silent(libver <- Rhdf5lib::getHdf5Version())
expect_identical(libver, "1.10.6")
