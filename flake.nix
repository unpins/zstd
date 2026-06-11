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
      # shell scripts we don't ship), so pin a curated 3-page tree via
      # winManRoot rather than fall back to the full graft. The native side
      # curates its own share/man in postInstall. zstdmt has no upstream page.
      pkgsX = unpins-lib.inputs.nixpkgs.legacyPackages.x86_64-linux;
      winMan = pkgsX.runCommand "zstd-win-man" { } ''
        mkdir -p "$out/share/man/man1"
        for p in zstd unzstd zstdcat; do
          zcat ${pkgsX.zstd.man}/share/man/man1/$p.1.gz > "$out/share/man/man1/$p.1"
        done
      '';
    in
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "zstd";
      winManRoot = winMan;
      build = pkgs:
        let
          pruned = pkgs.pkgsStatic.zstd.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + "\n" + ''
              for o in $outputs; do
                d="''${!o}"
                if [ -d "$d/bin" ]; then
                  find "$d/bin" -mindepth 1 -maxdepth 1 \
                    ! -name 'zstd' ! -name 'zstd.exe' -delete
                fi
                # Curate man to the shipped commands: zstd + the unzstd/
                # zstdcat/zstdmt aliases. Drop the shell-script pages
                # (zstdgrep, zstdless) we don't carry; zstdmt has no
                # upstream page. Otherwise withMan embeds all 5.
                if [ -d "$d/share/man/man1" ]; then
                  find "$d/share/man/man1" -mindepth 1 -maxdepth 1 \
                    ! -name 'zstd.1*' ! -name 'unzstd.1*' ! -name 'zstdcat.1*' \
                    -delete
                fi
              done
            '';
          });
        in
        unpins-lib.lib.withAliases pkgs
          {
            primary = "zstd";
            aliases = [ "unzstd" "zstdcat" "zstdmt" ];
          }
          pruned;
      # Mingw cmake build doesn't emit the unzstd/zstdcat/zstdmt symlinks
      # that the unix install adds, so nothing to prune — just embed the
      # multicall aliases as UNPIN_META.
      windowsBuild = pkgs:
        let cross = unpins-lib.lib.mingwStaticCross pkgs; in
        unpins-lib.lib.withAliases pkgs
          {
            primary = "zstd.exe";
            aliases = [ "unzstd" "zstdcat" "zstdmt" ];
          }
          cross.zstd;
    };
}
