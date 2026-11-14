{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "nixos-mac-style";
  version = "1.0";
  src = ./.;
  installPhase = ''
    mkdir -p $out/share/plymouth/themes/nixos-mac-style
    cp -r * $out/share/plymouth/themes/nixos-mac-style/
    find $out/share/plymouth/themes/ -name \*.plymouth -exec sed -i "s@\/usr\/@$out\/@" {} \;
  '';
}
