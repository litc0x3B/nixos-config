{ ... }:
{
  home.sessionVariables = rec {
    TERMINAL = "kitty";
    EDITOR = "nvim";
    SUDO_EDITOR = EDITOR;
    # PROTON_ENABLE_WAYLAND = 1;
    PROTON_USE_XALIA=0;
  };

}
