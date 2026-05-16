# zstd

Standalone build of [zstd](https://github.com/facebook/zstd).

[![CI](https://github.com/unpins/zstd/actions/workflows/zstd.yml/badge.svg)](https://github.com/unpins/zstd/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) project — native single-binary builds with no third-party runtime dependencies.

## Installation

Install with [unpin](https://github.com/unpins/unpin):

```bash
unpin zstd
```

Or run without installing:

```bash
unpin run zstd
```

`unpin install` creates the multicall aliases (`unzstd`, `zstdcat`, `zstdmt`) alongside `zstd`. Each alias dispatches via `argv[0]` to the same binary.

## Build locally

```bash
nix build github:unpins/zstd
./result/bin/zstd
```

Or run directly:

```bash
nix run github:unpins/zstd
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual download

The [Releases](https://github.com/unpins/zstd/releases) page has standalone binaries for manual download.
