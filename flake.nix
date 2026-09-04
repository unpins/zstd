{
  description = "zstd as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # zstd is a multicall binary with `unzstd`, `zstdcat`, `zstdmt` as
  # argv[0]-dispatch symlinks plus two shell scripts (`zstdgrep`, `zstdless`)
  # that need a system shell + grep/less to work. Keep only the multicall and
  # embed the aliases as UNPIN_META so unpin's installer recreates the
  # dispatch links.
  outputs = { self, unpins-lib }:
    let
      # Windows man fallback case: zstd's cmake build installs no man on the
      # mingw cross (the man install is gated on UNIX, false for mingw), so the
      # windows .exe can't harvest its own man the way every other target does.
      # nixpkgs' x86_64 zstd.man carries 5 pages (incl. the zstdgrep/zstdless
      # shell scripts we don't ship), so pin a curated tree via winManRoot
      # rather than fall back to the full graft. The native side curates its
      # own share/man in postInstall.
      pkgsX = unpins-lib.inputs.nixpkgs.legacyPackages.x86_64-linux;
      winMan = pkgsX.runCommand "zstd-win-man" { } ''
        mkdir -p "$out/share/man/man1"
        for p in zstd unzstd zstdcat; do
          zcat ${pkgsX.zstd.man}/share/man/man1/$p.1.gz > "$out/share/man/man1/$p.1"
        done
        ${zstdmtStub}
      '';
      # `zstdmt` is the third alias of the same binary and `zstd.1` documents it
      # by name — its NAME line reads "zstd, zstdmt, unzstd, zstdcat" and the
      # body says `zstdmt` is `zstd -T0`. Upstream's install creates the zstdmt
      # BINARY link (programs/Makefile:419) and the unzstd.1/zstdcat.1 man links
      # (:424-425), then stops without the third — the same dangling-line slip
      # that cost procps-ng its `pkill.1`. This file used to say zstdmt had no
      # upstream page; it has one, under another name.
      zstdmtStub = ''printf '.so man1/zstd.1\n' > "$out/share/man/man1/zstdmt.1"'';
    in
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "zstd";
      smoke = [ "--version" ];
      smokePattern = "Zstandard CLI .*v[0-9]+\\.[0-9]+";

      # Build via the unpin-llvm engine + emit a bitcode multicall module.
      engine = "unpin-llvm";
      multicall = {
        # The `.exe` on the engine too, not the nixpkgs mingw-gcc cross.
        windows = true;
        programs = [{ name = "zstd"; aliases = [ "unzstd" "zstdcat" "zstdmt" ]; }];
      };
      winManRoot = winMan;
      build = pkgs:
        let
          base = pkgs.pkgsStatic.zstd;
          runTests = base.stdenv.buildPlatform.canExecute base.stdenv.hostPlatform;
          pruned = base.overrideAttrs (old: {
            doCheck = runTests;
            # doCheck alone runs ctest against a build that registered no
            # tests ("No tests were found!!!") — the cmake project only adds
            # them under this flag. With it, `playTests` drives the CLI
            # through its functional suite and passes under static-musl. Tied
            # to `runTests` and not set unconditionally: on the crosses the
            # suite cannot run anyway, and building test binaries that nothing
            # executes is cost and cross-risk for nothing.
            cmakeFlags = (old.cmakeFlags or [ ])
              ++ pkgs.lib.optionals runTests [ "-DZSTD_BUILD_TESTS=ON" ];
            postInstall = (old.postInstall or "") + "\n" + ''
              for o in $outputs; do
                d="''${!o}"
                if [ -d "$d/bin" ]; then
                  find "$d/bin" -mindepth 1 -maxdepth 1 \
                    ! -name 'zstd' ! -name 'zstd.exe' -delete
                fi
                # Curate man to the shipped commands: zstd + the unzstd/
                # zstdcat/zstdmt aliases. Drop the shell-script pages
                # (zstdgrep, zstdless) we don't carry. Otherwise withMan embeds
                # all 5. zstdmt's stub is written after the prune — see
                # zstdmtStub above for why it is written at all.
                if [ -d "$d/share/man/man1" ]; then
                  find "$d/share/man/man1" -mindepth 1 -maxdepth 1 \
                    ! -name 'zstd.1*' ! -name 'unzstd.1*' ! -name 'zstdcat.1*' \
                    -delete
                  printf '.so man1/zstd.1\n' > "$d/share/man/man1/zstdmt.1"
                fi
              done
            '';
          });
        in
        pruned;
      # Mingw cmake build doesn't emit the unzstd/zstdcat/zstdmt symlinks
      # that the unix install adds, so nothing to prune here.
      windowsBuild = pkgs:
        let cross = unpins-lib.lib.mingwStaticCross pkgs; in
        cross.zstd;
    };
}
