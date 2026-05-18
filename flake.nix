{
  description = "Standalone build of zstd";

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
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "zstd";
      windows = true;
      build = pkgs:
        let
          pruned = pkgs.pkgsStatic.zstd.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + "\n" + ''
              for o in $outputs; do
                d="''${!o}"
                [ -d "$d/bin" ] || continue
                find "$d/bin" -mindepth 1 -maxdepth 1 \
                  ! -name 'zstd' ! -name 'zstd.exe' -delete
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
    };
}
