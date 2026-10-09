{ pkgs, lib, ... }:
let
  wrap =
    pkg:
    pkgs.symlinkJoin {
      name = pkg.name;
      meta = pkg.meta;
      paths = [ pkg ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${pkg.meta.mainProgram} --add-flags "--disable-features=WaylandFractionalScaleV1"
      '';
    };
  overlay = final: prev: {
    vscode-fhs = wrap prev.vscode-fhs;
    obsidian = wrap prev.obsidian;
    vesktop = wrap prev.vesktop;
  };
in
{
  # nixpkgs.overlays = [
  #   overlay
  # ];
}
