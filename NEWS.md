# devianLM 1.0.5

## Fixes
- Fixed a bug that prevented the propagation of 'alpha', 'n_sims', and 'n_threads' parameters when using the devianlm_stats() function
- Fixed a bug related to the threshold: the user's design matrix is used for the threshold estimation, while a different design matrix is used for the estimation of the studentized residuals (with an Added column of '1'). This is corrected according to the package's documentation: the user has to specify the complete design matrix.

---

# devianLM 1.0.4

## Fixes
- Fixed open-mp library specific check ERRORs on r-release-macos-x86_64 and r-oldrel-macos-x86_64.
- The documentation now states that the intercept must be explicitly added to the model design, if necessary.

---

# devianLM 1.0.3

## Fixes
- Fixed installation failure on CRAN systems without OpenMP support by adding proper compiler flags and safe fallbacks in the C++ code.
- Package now compiles and loads correctly on Linux, macOS, and Windows in CRAN test environments.

## Other
- Internal code cleanup in `src/` and `DESCRIPTION` for CRAN compliance.
- Updated examples in documentation to reduce runtime on CRAN checks.

## Documentation
- Added bibliographic reference to the methodology in `DESCRIPTION`.
