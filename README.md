# zstd

[zstd](https://github.com/facebook/zstd) as a single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/zstd/actions/workflows/zstd.yml/badge.svg)](https://github.com/unpins/zstd/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install zstd`.

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

## Man pages

The man pages for the shipped commands — `zstd`, `unzstd`, `zstdcat`, `zstdmt` — are embedded in the binary; read one with `unpin man zstd`, e.g. `unpin man zstd unzstd`. The pages for the shell-script wrappers (`zstdgrep`, `zstdless`) are dropped, since this package ships only `zstd` and its aliases.

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

## Build notes

- **Multicall:** one `zstd` binary; `unzstd`/`zstdcat`/`zstdmt` are `argv[0]`-dispatch aliases (`unpin install zstd` creates the command names). The shell-script wrappers (`zstdgrep`/`zstdless`) are dropped under the single-binary policy.
- **Windows:** built with mingw-w64.
- **Man pages:** the `zstd`/`unzstd`/`zstdcat`/`zstdmt` pages are embedded; read with `unpin man zstd`.
- **Not included:** compressing to or reading gzip, xz, lzma and lz4 (`--format=gzip|xz|lzma|lz4`), and decoding frames older than format v0.8 (zstd v0.5–v0.7). The nixpkgs build leaves all of them off.
- **Tests:** upstream's `playTests` suite runs during the build on the targets the build machine can execute (the native Linux and macOS builds, and Linux i686). Windows and the other cross targets get the `--version` smoke test only.
