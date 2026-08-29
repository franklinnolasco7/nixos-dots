# Returns a `writeShellScriptBin` derivation installed to
# ~/.local/libexec/fastfetch/pkgs. The nix-store closure queries are slow
# (~400ms total), so results are cached keyed by the current generation
# fingerprints (readlinks, ~1ms); the cache is invalidated on every rebuild.
# Reports system and user store counts separately as:
#   <system-count> (nix-system), <user-count> (nix-user)
#
# The awk filter mirrors fastfetch's own isValidNixPkg() heuristic so the
# number matches the built-in packages module while running ~60x faster.
{
  pkgs,
}:

pkgs.writeShellScriptBin "pkgs" ''
  set -eu

  coreutils="${pkgs.coreutils}"
  nix_store="${pkgs.nix}"
  gawk="${pkgs.gawk}"

  cache_dir=''${XDG_CACHE_HOME:-$HOME/.cache}/fastfetch-extra
  cache_file="$cache_dir/pkgs"

  profile_system=/run/current-system
  profile_user=/etc/profiles/per-user/''${USER:-$($coreutils/bin/id -un)}

  # Generation fingerprints: readlink resolves the profile symlinks to their
  # store paths, which change on every rebuild.
  fingerprint="$($coreutils/bin/readlink -f "$profile_system" 2>/dev/null || true) $($coreutils/bin/readlink -f "$profile_user" 2>/dev/null || true)"

  if [ -r "$cache_file" ] && {
    IFS= read -r cached_fp
    IFS= read -r cached_system
    IFS= read -r cached_user
  } <"$cache_file" && [ "$cached_fp" = "$fingerprint" ]; then
    count_system="$cached_system"
    count_user="$cached_user"
  else
    awk_filter='
    {
      b = $0; sub(".*/", "", b);
      if (b ~ /^nixos-system-nixos-/) next;
      if (b ~ /-(doc|man|info|dev|bin)$/) next;
      if (b ~ /[0-9]\.[0-9]/) n++;
    }
    END { print n }
    '

    count_system=$($nix_store/bin/nix-store -q --requisites "$profile_system" 2>/dev/null | $gawk/bin/gawk "$awk_filter")
    count_user=$($nix_store/bin/nix-store -q --requisites "$profile_user" 2>/dev/null | $gawk/bin/gawk "$awk_filter")

    mkdir -p "$cache_dir"
    printf '%s\n%s\n%s\n' "$fingerprint" "$count_system" "$count_user" >"$cache_file"
  fi

  printf '%s (nix-system), %s (nix-user)\n' "$count_system" "$count_user"
''
