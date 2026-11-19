{ pkgs, agypatch,... }:
pkgs.antigravity-hub.overrideAttrs (oldAttrs: rec {
  patch = agypatch;

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
    pkgs.python3
  ];

  postInstall = (oldAttrs.postInstall or "") + ''
    chmod +w $out/share/antigravity/resources/bin/language_server
    python3 ${patch}/manager.py patch manager --path-manager $out/share/antigravity/resources/bin/language_server
    rm $out/share/antigravity/resources/bin/language_server.agybak
  '';
})
