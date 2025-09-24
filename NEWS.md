# devianLM 1.0.3

## Fixes
- Fixed installation failure on CRAN systems without OpenMP support by adding proper compiler flags and safe fallbacks in the C++ code.
- Package now compiles and loads correctly on Linux, macOS, and Windows in CRAN test environments.

## Other
- Internal code cleanup in `src/` and `DESCRIPTION` for CRAN compliance.
- Updated examples in documentation to reduce runtime on CRAN checks.

## Documentation
- Added bibliographic reference to the methodology in `DESCRIPTION`