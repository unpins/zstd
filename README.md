# zstd

Standalone build of [zstd](https://github.com/facebook/zstd).

[![CI](https://github.com/unpins/zstd/actions/workflows/zstd.yml/badge.svg)](https://github.com/unpins/zstd/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) project — native single-binary builds with no third-party runtime dependencies.

## Usage

Run the `zstd` program with [unpin](https://github.com/unpins/unpin):

```bash
unpin zstd -19 file     # compress -> file.zst
unpin zstd -d file.zst  # decompress
```

To install it onto your PATH:

```bash
unpin install zstd
```

Installing also creates the `unzstd`, `zstdcat`, `zstdmt` commands.

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

## Man pages

The man pages for the shipped commands — `zstd`, `unzstd`, `zstdcat` — are embedded in the binary; read one with `unpin man zstd`, e.g. `unpin man zstd unzstd`. The pages for the shell-script wrappers (`zstdgrep`, `zstdless`) are dropped, since this package ships only `zstd` and its aliases. (`zstdmt` has no upstream man page — it's `zstd` in multi-threaded mode.)
