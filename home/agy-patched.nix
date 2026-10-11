{ pkgs, agypatch,... }:
pkgs.antigravity-cli.overrideAttrs (oldAttrs: rec {
  patch = agypatch;

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
    pkgs.python3
  ];

  postInstall = (oldAttrs.postInstall or "") + ''
    chmod +w $out/bin/agy
    python3 ${patch}/manager.py patch cli --path-cli $out/bin/agy
    rm $out/bin/agy.agybak
  '';
})