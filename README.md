[![Build Status](https://img.shields.io/travis/netorcai/netorcai-client-fortran/master.svg?maxAge=600)](https://travis-ci.org/netorcai/netorcai-client-fortran)
[![Coverage Status](https://img.shields.io/codecov/c/github/netorcai/netorcai-client-fortran/master.svg?maxAge=600)](https://codecov.io/github/netorcai/netorcai-client-fortran)

netorcai-client-fortran
=================
FORTRAN 2003 version of the [netorcai] client library.

This client make few assumptions (that will not be fixed unless someone propose a pull request to solve them):
- The client target 64 bits Linux systems only (wrapping system calls is needed to handle sockets and processes in FORTRAN)
- UTF-8 is not supported (not nativelly by the language nor actually supported by gfortran currently): non-ascii unicode characters are replaced by '?' ones
- FORTRAN 2003 is used for the following reasons:
    - Standard/Working variable-length strings (introduced in FORTRAN 2003) are not available before and fixed strings results in both an insane API and an innefficient parser
    - Object-oriented (introduced in FORTRAN 2003) provide a cleaner and more usable API
    - It would be hard to write internal data structures (eg. variable-length generic arrays) similar to those required for the parser that would otherwise be much slower (with a quadratic complexity rather than simply linear)
    - FORTRAN 2008 is not currently fully supported by gfortran

Installation
============
The library uses the [Meson] build system (and therefore uses [Ninja]).

``` bash
# Create build directory.
meson build # --prefix=/desired/installation/prefix

# Build the library (and the unit test executables) in the build directory.
ninja -C build

# Run the unit tests
ninja -C build test

# Install the library
ninja -C build install
```

[netorcai]: https://github.com/netorcai/
[Meson]: https://mesonbuild.com/
[Ninja]: https://ninja-build.org/
