{ pkgs, ... }:
let
  curPkgs =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/b1b875982b17dabde9b4a37f3e229e74913e6db3.tar.gz";
        sha256 = "sha256-zVxLZiSnmaaPLwnhj7pwmqe3axBg/C6nG5JZsJMh2g4=";
      })
      {
        inherit (pkgs) system;
        config.allowUnfree = true;
      };
in
curPkgs.antigravity-cli.overrideAttrs (oldAttrs: rec {

  patch = pkgs.fetchFromGitHub {
    owner = "QNIX-Dev";
    repo = "eligibility-antigravity-patcher";
    rev = "13173ad98620003db2d5097cbb47cd65213892b9";
    hash = "sha256-PXm2iX9Nuu6wv3tjV5m/MlGbA0p/PBHbTv1l4zqRliA=";
  };

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
    pkgs.python3
  ];


  postInstall = (oldAttrs.postInstall or "") + ''
    chmod +w $out/bin/agy
    python3 ${patch}/manager.py patch cli --path-cli $out/bin/agy
    rm $out/bin/agy.agybak
  '';
})