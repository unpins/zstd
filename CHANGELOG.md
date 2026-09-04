# Changelog

## [Unreleased]

### Changed

- The Windows binary is now built by the same compiler as the Linux and macOS
  ones, and is 22% smaller (1.08 MB to 844 KB). Checked on Windows 10:
  compressing a file gives a byte-identical archive, archives written by the
  previous binary still decompress to the original, and `unzstd`, `zstdcat` and
  `zstdmt` still work.

  It now uses the Universal C Runtime, which is part of Windows 10 and later.
  On Windows 7 or 8.1 that runtime has to be installed first — it comes through
  Windows Update. The previous binary did not need it.
